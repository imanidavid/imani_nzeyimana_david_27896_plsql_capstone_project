-- Sequences for PKs used by PL/SQL / triggers

-- Product IDs (> 40 existing)
CREATE SEQUENCE seq_product
  START WITH 100
  INCREMENT BY 1
  NOCACHE;

-- Cost history IDs (> 80 existing)
CREATE SEQUENCE seq_cost_history
  START WITH 1000
  INCREMENT BY 1
  NOCACHE;

-- Sales order IDs (> 2000 existing)
CREATE SEQUENCE seq_sales_order
  START WITH 5000
  INCREMENT BY 1
  NOCACHE;

-- Sales line IDs (> 3000 existing)
CREATE SEQUENCE seq_sales_line
  START WITH 10000
  INCREMENT BY 1
  NOCACHE;

-- Margin baseline IDs (> 4000 existing)
CREATE SEQUENCE seq_margin_baseline
  START WITH 10000
  INCREMENT BY 1
  NOCACHE;

-- Margin alert IDs (used by alert generation logic)
CREATE SEQUENCE seq_margin_alert
  START WITH 100
  INCREMENT BY 1
  NOCACHE;

-- Audit log IDs (used by audit triggers)
CREATE SEQUENCE seq_audit_log
  START WITH 100
  INCREMENT BY 1
  NOCACHE;

-- Helpful indexes on foreign keys for performance

-- SALES_ORDER
CREATE INDEX idx_sales_order_branch
  ON SALES_ORDER (branch_id);

-- SALES_LINE
CREATE INDEX idx_sales_line_order
  ON SALES_LINE (order_id);

CREATE INDEX idx_sales_line_product
  ON SALES_LINE (product_id);

-- COST_HISTORY
CREATE INDEX idx_cost_history_product
  ON COST_HISTORY (product_id);

-- MARGIN_ALERT
CREATE INDEX idx_margin_alert_order
  ON MARGIN_ALERT (order_id);

CREATE INDEX idx_margin_alert_line
  ON MARGIN_ALERT (line_id);

CREATE INDEX idx_margin_alert_product
  ON MARGIN_ALERT (product_id);

-- MARGIN_BASELINE
CREATE INDEX idx_margin_baseline_prod_branch
  ON MARGIN_BASELINE (product_id, branch_id);
