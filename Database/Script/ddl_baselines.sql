
BEGIN
  EXECUTE IMMEDIATE '
    ALTER TABLE MARGIN_BASELINE
    ADD CONSTRAINT uq_margin_baseline_prod_branch
    UNIQUE (product_id, branch_id, period_start)
  ';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -2261 THEN
      RAISE;
    END IF;
END;
/

COMMENT ON TABLE MARGIN_BASELINE IS
  'Baseline margin statistics used for anomaly detection';

COMMENT ON COLUMN MARGIN_BASELINE.product_id IS
  'Product whose margin baseline is stored';

COMMENT ON COLUMN MARGIN_BASELINE.branch_id IS
  'Branch-specific baseline (NULL = global baseline)';

COMMENT ON COLUMN MARGIN_BASELINE.period_start IS
  'Start of the period (e.g. first day of month)';

COMMENT ON COLUMN MARGIN_BASELINE.avg_margin IS
  'Average margin percentage for the period';

COMMENT ON COLUMN MARGIN_BASELINE.stddev_margin IS
  'Standard deviation of margin for the period';
