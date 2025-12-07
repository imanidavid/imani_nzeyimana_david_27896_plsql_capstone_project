

-- 1) BRANCH
CREATE TABLE BRANCH (
  branch_id   NUMBER        PRIMARY KEY,
  name        VARCHAR2(100) NOT NULL UNIQUE,
  location    VARCHAR2(200)
);

-- 2) PRODUCT
CREATE TABLE PRODUCT (
  product_id  NUMBER         PRIMARY KEY,
  sku         VARCHAR2(50)   NOT NULL UNIQUE,
  name        VARCHAR2(200)  NOT NULL,
  category    VARCHAR2(100),
  cost_price  NUMBER(12,2)   NOT NULL,   -- latest cost snapshot
  list_price  NUMBER(12,2)   NOT NULL,
  active      CHAR(1)        DEFAULT 'Y' 
                              CHECK (active IN ('Y','N'))
);

-- 3) COST_HISTORY
CREATE TABLE COST_HISTORY (
  cost_id      NUMBER        PRIMARY KEY,
  product_id   NUMBER        NOT NULL
                              REFERENCES PRODUCT(product_id),
  effective_date DATE        NOT NULL,
  cost_price   NUMBER(12,2)  NOT NULL,
  created_by   VARCHAR2(50),
  created_on   DATE          DEFAULT SYSDATE
);

-- 4) SALES_ORDER
CREATE TABLE SALES_ORDER (
  order_id     NUMBER        PRIMARY KEY,
  order_date   DATE          DEFAULT SYSDATE NOT NULL,
  branch_id    NUMBER        NOT NULL
                              REFERENCES BRANCH(branch_id),
  customer_id  NUMBER,
  total_amount NUMBER(14,2)  NOT NULL
);

-- 5) SALES_LINE
CREATE TABLE SALES_LINE (
  line_id      NUMBER        PRIMARY KEY,
  order_id     NUMBER        NOT NULL
                              REFERENCES SALES_ORDER(order_id),
  product_id   NUMBER        NOT NULL
                              REFERENCES PRODUCT(product_id),
  qty          NUMBER(10,2)  DEFAULT 1 NOT NULL
                              CHECK (qty > 0),
  unit_price   NUMBER(12,2)  NOT NULL,
  discount_pct NUMBER(5,2)   DEFAULT 0
                              CHECK (discount_pct BETWEEN 0 AND 100),
  line_total   NUMBER(14,2)  NOT NULL,
  created_on   DATE          DEFAULT SYSDATE
);

-- 6) MARGIN_ALERT
CREATE TABLE MARGIN_ALERT (
  alert_id    NUMBER        PRIMARY KEY,
  created_on  DATE          DEFAULT SYSDATE NOT NULL,
  order_id    NUMBER        REFERENCES SALES_ORDER(order_id),
  line_id     NUMBER        REFERENCES SALES_LINE(line_id),
  product_id  NUMBER        NOT NULL
                             REFERENCES PRODUCT(product_id),
  branch_id   NUMBER        REFERENCES BRANCH(branch_id),
  margin_pct  NUMBER(6,2)   NOT NULL,
  reason      VARCHAR2(400) NOT NULL,
  status      VARCHAR2(20)  DEFAULT 'OPEN' NOT NULL
                             CHECK (status IN ('OPEN','REVIEWED','CLOSED')),
  created_by  VARCHAR2(50)
);

-- 7) MARGIN_BASELINE
CREATE TABLE MARGIN_BASELINE (
  baseline_id  NUMBER       PRIMARY KEY,
  product_id   NUMBER       NOT NULL
                             REFERENCES PRODUCT(product_id),
  branch_id    NUMBER       REFERENCES BRANCH(branch_id),
  period_start DATE         NOT NULL,
  avg_margin   NUMBER(6,2)  NOT NULL,
  stddev_margin NUMBER(6,2) NOT NULL,
  CONSTRAINT u_baseline UNIQUE (product_id, branch_id, period_start)
);

-- 8) AUDIT_LOG
CREATE TABLE AUDIT_LOG (
  audit_id    NUMBER        PRIMARY KEY,
  object_type VARCHAR2(50)  NOT NULL,   -- e.g. 'PRODUCT','SALES_LINE'
  object_id   NUMBER        NOT NULL,   -- PK of the changed row
  changed_on  DATE          DEFAULT SYSDATE NOT NULL,
  changed_by  VARCHAR2(50),
  change_type VARCHAR2(50),             -- INSERT / UPDATE / DELETE
  old_value   VARCHAR2(4000),
  new_value   VARCHAR2(4000)
);

-- 9) Table of blocked calendar dates (holidays)
CREATE TABLE HOLIDAY_CALENDAR (
  holiday_date   DATE PRIMARY KEY,
  description    VARCHAR2(200)
);

-- Indexes (simple ones to help joins)

CREATE INDEX idx_sales_order_branch ON SALES_ORDER(branch_id);
CREATE INDEX idx_sales_line_order  ON SALES_LINE(order_id);
CREATE INDEX idx_sales_line_prod   ON SALES_LINE(product_id);
CREATE INDEX idx_alert_product     ON MARGIN_ALERT(product_id);
CREATE INDEX idx_cost_hist_prod_dt ON COST_HISTORY(product_id, effective_date);
