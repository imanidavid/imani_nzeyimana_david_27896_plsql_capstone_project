
CREATE OR REPLACE PACKAGE margin_mon_pkg AS

  -- Default minimum acceptable margin (percent)
  g_default_threshold CONSTANT NUMBER := 15;

  FUNCTION get_cost_at_sale(
    p_product_id IN NUMBER,
    p_order_date IN DATE
  ) RETURN NUMBER;

  -- Calculate margin % for a specific SALES_LINE row.
  FUNCTION calc_line_margin(
    p_line_id IN NUMBER
  ) RETURN NUMBER;

  -- Evaluate all lines in an order and insert alerts
  PROCEDURE evaluate_order_margin(
    p_order_id IN NUMBER
  );

  -- Recompute simple baselines (avg margin per product)
  PROCEDURE refresh_baselines(
    p_period_start IN DATE DEFAULT TRUNC(ADD_MONTHS(SYSDATE, -1), 'MM')
  );

END margin_mon_pkg;
/


CREATE OR REPLACE PACKAGE BODY margin_mon_pkg AS

  -- Helper: get_cost_at_sale
  FUNCTION get_cost_at_sale(
    p_product_id IN NUMBER,
    p_order_date IN DATE
  ) RETURN NUMBER IS
    v_cost NUMBER;
  BEGIN
    SELECT ch.cost_price
    INTO   v_cost
    FROM   COST_HISTORY ch
    WHERE  ch.product_id     = p_product_id
    AND    ch.effective_date <= NVL(p_order_date, SYSDATE)
    ORDER  BY ch.effective_date DESC
    FETCH FIRST 1 ROWS ONLY;

    RETURN v_cost;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      BEGIN
        SELECT cost_price
        INTO   v_cost
        FROM   PRODUCT
        WHERE  product_id = p_product_id;
        RETURN v_cost;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RETURN NULL;
      END;
  END get_cost_at_sale;

  -- calc_line_margin
  FUNCTION calc_line_margin(
    p_line_id IN NUMBER
  ) RETURN NUMBER IS
    v_product_id  SALES_LINE.product_id%TYPE;
    v_qty         SALES_LINE.qty%TYPE;
    v_unit_price  SALES_LINE.unit_price%TYPE;
    v_disc        SALES_LINE.discount_pct%TYPE;
    v_order_id    SALES_LINE.order_id%TYPE;
    v_order_date  SALES_ORDER.order_date%TYPE;
    v_cost        NUMBER;
    v_net_price   NUMBER;
    v_margin_pct  NUMBER;
  BEGIN
    -- Get line + its order date
    SELECT sl.product_id,
           sl.qty,
           sl.unit_price,
           NVL(sl.discount_pct, 0),
           sl.order_id,
           so.order_date
    INTO   v_product_id,
           v_qty,
           v_unit_price,
           v_disc,
           v_order_id,
           v_order_date
    FROM   SALES_LINE sl
    JOIN   SALES_ORDER so ON so.order_id = sl.order_id
    WHERE  sl.line_id = p_line_id;

    v_cost := get_cost_at_sale(v_product_id, v_order_date);

    IF v_cost IS NULL THEN
      RETURN NULL;
    END IF;

    v_net_price := v_unit_price * (1 - v_disc / 100);

    IF v_net_price <= 0 THEN
      RETURN NULL;
    END IF;

    v_margin_pct := ((v_net_price - v_cost) / v_net_price) * 100;

    RETURN ROUND(v_margin_pct, 2);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END calc_line_margin;

  -- Internal helper: insert one alert row
  PROCEDURE insert_alert(
    p_order_id    IN NUMBER,
    p_line_id     IN NUMBER,
    p_product_id  IN NUMBER,
    p_branch_id   IN NUMBER,
    p_margin_pct  IN NUMBER,
    p_reason      IN VARCHAR2
  ) IS
    v_new_id NUMBER;
  BEGIN
    SELECT NVL(MAX(alert_id), 0) + 1
    INTO   v_new_id
    FROM   MARGIN_ALERT;

    INSERT INTO MARGIN_ALERT (
      alert_id,
      created_on,
      order_id,
      line_id,
      product_id,
      branch_id,
      margin_pct,
      reason,
      status,
      created_by
    ) VALUES (
      v_new_id,
      SYSDATE,
      p_order_id,
      p_line_id,
      p_product_id,
      p_branch_id,
      p_margin_pct,
      p_reason,
      'OPEN',
      USER
    );
  END insert_alert;

  -- evaluate_order_margin
  PROCEDURE evaluate_order_margin(
    p_order_id IN NUMBER
  ) IS
    v_branch_id  SALES_ORDER.branch_id%TYPE;
    v_margin     NUMBER;
    v_threshold  NUMBER := g_default_threshold;
  BEGIN
    -- Get branch for the order
    SELECT branch_id
    INTO   v_branch_id
    FROM   SALES_ORDER
    WHERE  order_id = p_order_id;

    -- Loop all lines in the order
    FOR r_line IN (
      SELECT line_id, product_id
      FROM   SALES_LINE
      WHERE  order_id = p_order_id
    ) LOOP
      v_margin := calc_line_margin(r_line.line_id);

      IF v_margin IS NULL THEN
        CONTINUE;
      END IF;

      IF v_margin < v_threshold THEN
        insert_alert(
          p_order_id   => p_order_id,
          p_line_id    => r_line.line_id,
          p_product_id => r_line.product_id,
          p_branch_id  => v_branch_id,
          p_margin_pct => v_margin,
          p_reason     => 'Margin below threshold ' || v_threshold || '%'
        );
      END IF;
    END LOOP;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL; 
  END evaluate_order_margin;

  -- Simple version: recompute avg margin per product (global)
  PROCEDURE refresh_baselines(
    p_period_start IN DATE
  ) IS
  BEGIN
    -- Clear existing baselines for that period
    DELETE FROM MARGIN_BASELINE
    WHERE  period_start = TRUNC(p_period_start);

    INSERT INTO MARGIN_BASELINE (
      baseline_id,
      product_id,
      branch_id,
      period_start,
      avg_margin,
      stddev_margin
    )
    SELECT
      ROW_NUMBER() OVER (ORDER BY product_id) AS baseline_id,
      product_id,
      NULL AS branch_id,
      TRUNC(p_period_start) AS period_start,
      AVG(margin_pct) AS avg_margin,
      NVL(STDDEV(margin_pct), 0) AS stddev_margin
    FROM (
      SELECT
        sl.product_id,
        margin_mon_pkg.calc_line_margin(sl.line_id) AS margin_pct
      FROM   SALES_LINE sl
      JOIN   SALES_ORDER so ON so.order_id = sl.order_id
      WHERE  so.order_date >= TRUNC(p_period_start)
      AND    so.order_date <  ADD_MONTHS(TRUNC(p_period_start), 1)
    )
    WHERE margin_pct IS NOT NULL
    GROUP BY product_id;

    COMMIT;
  END refresh_baselines;

END margin_mon_pkg;
/
