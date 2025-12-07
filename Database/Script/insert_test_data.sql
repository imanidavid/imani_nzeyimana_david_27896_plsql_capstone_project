
SET SERVEROUTPUT ON;
--  BRANCH: 4 branches
INSERT INTO BRANCH (branch_id, name, location) VALUES (1, 'Kigali HQ',    'Kigali, Rwanda');
INSERT INTO BRANCH (branch_id, name, location) VALUES (2, 'Huye Branch',  'Huye, Rwanda');
INSERT INTO BRANCH (branch_id, name, location) VALUES (3, 'Musanze Branch','Musanze, Rwanda');
INSERT INTO BRANCH (branch_id, name, location) VALUES (4, 'Rubavu Branch', 'Rubavu, Rwanda');

COMMIT;

-- PRODUCT: 40 products across categories
BEGIN
  FOR i IN 1..10 LOOP
    INSERT INTO PRODUCT (product_id, sku, name, category, cost_price, list_price, active)
    VALUES (
      i,
      'BEV-' || TO_CHAR(i, 'FM00'),
      'Beverage ' || i,
      'Beverages',
      300 + i * 5,          
      500 + i * 10,         
      'Y'
    );
  END LOOP;

  FOR i IN 11..20 LOOP
    INSERT INTO PRODUCT (product_id, sku, name, category, cost_price, list_price, active)
    VALUES (
      i,
      'SNK-' || TO_CHAR(i, 'FM00'),
      'Snack ' || (i-10),
      'Snacks',
      200 + (i-10) * 5,
      350 + (i-10) * 8,
      'Y'
    );
  END LOOP;

  FOR i IN 21..30 LOOP
    INSERT INTO PRODUCT (product_id, sku, name, category, cost_price, list_price, active)
    VALUES (
      i,
      'ELE-' || TO_CHAR(i, 'FM00'),
      'Electronic ' || (i-20),
      'Electronics',
      15000 + (i-20) * 500,
      22000 + (i-20) * 1000,
      'Y'
    );
  END LOOP;

  FOR i IN 31..40 LOOP
    INSERT INTO PRODUCT (product_id, sku, name, category, cost_price, list_price, active)
    VALUES (
      i,
      'HOM-' || TO_CHAR(i, 'FM00'),
      'Home Item ' || (i-30),
      'Home',
      3000 + (i-30) * 200,
      4500 + (i-30) * 300,
      'Y'
    );
  END LOOP;
END;
/

COMMIT;

--  COST_HISTORY: 2 cost records per product (old + current)
BEGIN
  FOR p IN 1..40 LOOP
    INSERT INTO COST_HISTORY (cost_id, product_id, effective_date, cost_price, created_by)
    VALUES (p * 2 - 1, p, ADD_MONTHS(TRUNC(SYSDATE), -3), (SELECT cost_price FROM PRODUCT WHERE product_id = p) - 100, 'system');

    INSERT INTO COST_HISTORY (cost_id, product_id, effective_date, cost_price, created_by)
    VALUES (p * 2, p, ADD_MONTHS(TRUNC(SYSDATE), -1), (SELECT cost_price FROM PRODUCT WHERE product_id = p), 'system');
  END LOOP;
END;
/

COMMIT;

--  SALES_ORDER: 120 orders over last 60 days
DECLARE
  v_order_id NUMBER := 1;
BEGIN
  FOR d IN REVERSE 0..59 LOOP
    FOR b IN 1..4 LOOP
      IF v_order_id > 120 THEN
        EXIT;
      END IF;

      INSERT INTO SALES_ORDER (order_id, order_date, branch_id, customer_id, total_amount)
      VALUES (
        v_order_id,
        TRUNC(SYSDATE) - d,
        b,
        CASE WHEN MOD(v_order_id, 5) = 0 THEN NULL ELSE MOD(v_order_id, 50) + 1 END,
        0  -- will update later
      );

      v_order_id := v_order_id + 1;
    END LOOP;
  END LOOP;
END;
/

COMMIT;

-- SALES_LINE: 1–3 lines per order, realistic prices & discounts
DECLARE
  v_line_id   NUMBER := 1;
  v_total     NUMBER;
  v_prod_id   NUMBER;
  v_qty       NUMBER;
  v_price     NUMBER;
  v_disc      NUMBER;
BEGIN
  FOR o IN (SELECT order_id, order_date, branch_id FROM SALES_ORDER) LOOP
    v_total := 0;

    FOR l IN 1..3 LOOP
      v_prod_id := MOD(o.order_id + l, 40) + 1;
      v_qty     := CASE WHEN l = 1 THEN 1
                        WHEN l = 2 THEN 3
                        ELSE 5 END;

      SELECT list_price INTO v_price FROM PRODUCT WHERE product_id = v_prod_id;

      v_disc := CASE
                  WHEN MOD(o.order_id, 10) = 0 THEN 25   -- heavy discount edge case
                  WHEN MOD(o.order_id, 3) = 0 THEN 10
                  ELSE 0
                END;

      INSERT INTO SALES_LINE (line_id, order_id, product_id, qty, unit_price, discount_pct, line_total, created_on)
      VALUES (
        v_line_id,
        o.order_id,
        v_prod_id,
        v_qty,
        v_price,
        v_disc,
        ROUND(v_qty * v_price * (1 - v_disc / 100), 2),
        o.order_date
      );

      v_total := v_total + ROUND(v_qty * v_price * (1 - v_disc / 100), 2);
      v_line_id := v_line_id + 1;
    END LOOP;

    UPDATE SALES_ORDER
      SET total_amount = v_total
    WHERE order_id = o.order_id;
  END LOOP;
END;
/

COMMIT;

--  MARGIN_BASELINE: simple seed baselines per product (global)
BEGIN
  FOR p IN 1..40 LOOP
    INSERT INTO MARGIN_BASELINE (baseline_id, product_id, branch_id, period_start, avg_margin, stddev_margin)
    VALUES (
      p,
      p,
      NULL,                                   -- global
      ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -1),   -- previous month
      20 + MOD(p, 10),                        -- 20–29%
      3 + MOD(p, 3)                           -- 3–5%
    );
  END LOOP;
END;
/

COMMIT;

-- MARGIN_ALERT: sample manual alerts (before triggers exist)
-- Later, PL/SQL logic will fill this automatically.
INSERT INTO MARGIN_ALERT (
  alert_id, created_on, order_id, line_id, product_id,
  branch_id, margin_pct, reason, status, created_by
)
VALUES (
  1, SYSDATE - 5, 10, 25, 3,
  1, 5.00, 'Very low margin due to high discount on Beverage 3', 'OPEN', 'tester'
);

INSERT INTO MARGIN_ALERT (
  alert_id, created_on, order_id, line_id, product_id,
  branch_id, margin_pct, reason, status, created_by
)
VALUES (
  2, SYSDATE - 2, 45, 120, 22,
  2, 8.50, 'Low margin after recent cost increase for Electronic 2', 'REVIEWED', 'tester'
);

COMMIT;

-- 9. AUDIT_LOG: sample manual audit records
-- Later, triggers will write to this.
INSERT INTO AUDIT_LOG (
  audit_id, object_type, object_id, changed_on, changed_by,
  change_type, old_value, new_value
)
VALUES (
  1, 'PRODUCT', 3, SYSDATE - 10, 'admin',
  'UPDATE', 'cost_price=320', 'cost_price=380'
);

INSERT INTO AUDIT_LOG (
  audit_id, object_type, object_id, changed_on, changed_by,
  change_type, old_value, new_value
)
VALUES (
  2, 'SALES_LINE', 25, SYSDATE - 5, 'manager',
  'UPDATE', 'discount_pct=10', 'discount_pct=25'
);

COMMIT;

PROMPT 'Phase V test data inserted successfully.';

-- Sample holidays (adjust for your country)
INSERT INTO HOLIDAY_CALENDAR (holiday_date, description)
VALUES (DATE '2025-01-01', 'New Year');

INSERT INTO HOLIDAY_CALENDAR (holiday_date, description)
VALUES (DATE '2025-04-07', 'Genocide Memorial');

COMMIT;
