-- validation_queries.sql

SET SERVEROUTPUT ON;

-- 1. Table row counts 
PROMPT == Table row counts ==;

SELECT 'BRANCH'          AS table_name, COUNT(*) AS row_count FROM BRANCH
UNION ALL
SELECT 'PRODUCT',        COUNT(*) FROM PRODUCT
UNION ALL
SELECT 'COST_HISTORY',   COUNT(*) FROM COST_HISTORY
UNION ALL
SELECT 'SALES_ORDER',    COUNT(*) FROM SALES_ORDER
UNION ALL
SELECT 'SALES_LINE',     COUNT(*) FROM SALES_LINE
UNION ALL
SELECT 'MARGIN_BASELINE',COUNT(*) FROM MARGIN_BASELINE
UNION ALL
SELECT 'MARGIN_ALERT',   COUNT(*) FROM MARGIN_ALERT
UNION ALL
SELECT 'AUDIT_LOG',      COUNT(*) FROM AUDIT_LOG
ORDER BY 1; 

-- 2. Basic NOT NULL / required-column checks
PROMPT == Check for unexpected NULLs in required columns ==;

-- PRODUCTS with missing required values
SELECT *
FROM PRODUCT
WHERE sku IS NULL
   OR name IS NULL
   OR cost_price IS NULL
   OR list_price IS NULL;

-- SALES_ORDER with missing required values

SELECT *
FROM SALES_ORDER
WHERE order_date IS NULL
   OR branch_id IS NULL
   OR total_amount IS NULL;

-- SALES_LINE with missing required values

SELECT *
FROM SALES_LINE
WHERE order_id IS NULL
   OR product_id IS NULL
   OR qty IS NULL
   OR unit_price IS NULL
   OR line_total IS NULL;


-- 3. Business rule checks: qty > 0, discount between 0 and 100

PROMPT == Check qty > 0 and discount_pct between 0 and 100 ==;

SELECT *
FROM SALES_LINE
WHERE qty <= 0
   OR discount_pct < 0
   OR discount_pct > 100;


-- 4. Check line_total consistency:
PROMPT == Check SALES_LINE line_total consistency ==;

SELECT line_id, order_id, product_id,
       qty, unit_price, discount_pct,
       line_total,
       ROUND(qty * unit_price * (1 - NVL(discount_pct,0)/100), 2) AS expected_total
FROM SALES_LINE
WHERE line_total <> ROUND(qty * unit_price * (1 - NVL(discount_pct,0)/100), 2);


-- 5. Check SALES_ORDER.total_amount = SUM(SALES_LINE.line_total)
PROMPT == Check SALES_ORDER total matches sum of its lines ==;

SELECT o.order_id,
       o.total_amount AS header_total,
       NVL(SUM(l.line_total), 0) AS lines_total,
       (o.total_amount - NVL(SUM(l.line_total),0)) AS diff
FROM SALES_ORDER o
LEFT JOIN SALES_LINE l
  ON o.order_id = l.order_id
GROUP BY o.order_id, o.total_amount
HAVING o.total_amount <> NVL(SUM(l.line_total),0);


-- 6. Orphan checks (FK-like validations)
PROMPT == Orphan check: SALES_LINE without matching PRODUCT or SALES_ORDER ==;

SELECT l.*
FROM SALES_LINE l
LEFT JOIN PRODUCT p ON l.product_id = p.product_id
LEFT JOIN SALES_ORDER o ON l.order_id = o.order_id
WHERE p.product_id IS NULL
   OR o.order_id IS NULL;


PROMPT == Orphan check: COST_HISTORY without matching PRODUCT ==;

SELECT ch.*
FROM COST_HISTORY ch
LEFT JOIN PRODUCT p ON ch.product_id = p.product_id
WHERE p.product_id IS NULL;


PROMPT == Orphan check: MARGIN_BASELINE without matching PRODUCT or BRANCH (when branch_id is NOT NULL) ==;

SELECT mb.*
FROM MARGIN_BASELINE mb
LEFT JOIN PRODUCT p ON mb.product_id = p.product_id
LEFT JOIN BRANCH b  ON mb.branch_id = b.branch_id
WHERE p.product_id IS NULL
   OR (mb.branch_id IS NOT NULL AND b.branch_id IS NULL);


PROMPT == Orphan check: MARGIN_ALERT references ==;

SELECT ma.*
FROM MARGIN_ALERT ma
LEFT JOIN PRODUCT p ON ma.product_id = p.product_id
LEFT JOIN BRANCH b  ON ma.branch_id = b.branch_id
LEFT JOIN SALES_ORDER o ON ma.order_id = o.order_id
LEFT JOIN SALES_LINE  l ON ma.line_id  = l.line_id
WHERE p.product_id IS NULL
   OR (ma.branch_id IS NOT NULL AND b.branch_id IS NULL)
   OR (ma.order_id IS NOT NULL AND o.order_id IS NULL)
   OR (ma.line_id  IS NOT NULL AND l.line_id  IS NULL);


-- 7. Check COST_HISTORY correctness: one latest record per product
PROMPT == Check COST_HISTORY: latest record per product ==;

SELECT ch.product_id,
       COUNT(*) AS records_per_product,
       MIN(effective_date) AS oldest_date,
       MAX(effective_date) AS newest_date
FROM COST_HISTORY ch
GROUP BY ch.product_id
ORDER BY ch.product_id;


-- 8. MARGIN_BASELINE sanity: one baseline per product for last month
PROMPT == Check MARGIN_BASELINE for previous month coverage ==;

SELECT product_id,
       COUNT(*) AS baseline_rows,
       MIN(period_start) AS min_period,
       MAX(period_start) AS max_period
FROM MARGIN_BASELINE
GROUP BY product_id
ORDER BY product_id;


-- 9. Sample distribution checks (to prove data looks realistic)
PROMPT == Sales distribution by branch ==;

SELECT b.name AS branch_name,
       COUNT(DISTINCT o.order_id) AS orders,
       COUNT(l.line_id) AS lines,
       SUM(l.line_total) AS sales_amount
FROM BRANCH b
LEFT JOIN SALES_ORDER o ON o.branch_id = b.branch_id
LEFT JOIN SALES_LINE  l ON l.order_id = o.order_id
GROUP BY b.name
ORDER BY sales_amount DESC;


PROMPT == Top 10 products by sales value ==;

SELECT p.product_id,
       p.name,
       p.category,
       SUM(l.line_total) AS total_sales
FROM PRODUCT p
JOIN SALES_LINE l ON l.product_id = p.product_id
GROUP BY p.product_id, p.name, p.category
ORDER BY total_sales DESC FETCH FIRST 10 ROWS ONLY;


-- 10. Check MARGIN_ALERT and AUDIT_LOG content (sample view)
PROMPT == Sample MARGIN_ALERT rows ==;

SELECT alert_id,
       created_on,
       order_id,
       line_id,
       product_id,
       branch_id,
       margin_pct,
       status,
       reason
FROM MARGIN_ALERT
ORDER BY created_on DESC;


PROMPT == Sample AUDIT_LOG rows ==;

SELECT audit_id,
       object_type,
       object_id,
       changed_on,
       changed_by,
       change_type
FROM AUDIT_LOG
ORDER BY changed_on DESC;


PROMPT 'Validation queries executed.';
