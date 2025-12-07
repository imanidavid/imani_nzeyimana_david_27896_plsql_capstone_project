-- 1. List all branches
SELECT branch_id, name, location
FROM BRANCH
ORDER BY branch_id;

-- 2. List all products with cost + list price
SELECT product_id, sku, name, category, cost_price, list_price, active
FROM PRODUCT
ORDER BY product_id;

-- 3. Show cost history per product
SELECT product_id, cost_id, effective_date, cost_price
FROM COST_HISTORY
ORDER BY product_id, effective_date DESC;

-- 4. List recent sales orders
SELECT order_id, order_date, branch_id, customer_id, total_amount
FROM SALES_ORDER
ORDER BY order_date DESC
FETCH FIRST 50 ROWS ONLY;

-- 5. Sales lines for a given order
SELECT line_id, order_id, product_id, qty, unit_price, discount_pct, line_total
FROM SALES_LINE
WHERE order_id = :order_id
ORDER BY line_id;

-- 6. Get all margin alerts
SELECT alert_id, created_on, order_id, line_id, product_id, margin_pct, reason, status
FROM MARGIN_ALERT
ORDER BY created_on DESC;

-- 7. Audit log view
SELECT audit_id, object_type, object_id, changed_on, changed_by, change_type
FROM AUDIT_LOG
ORDER BY audit_id DESC;
