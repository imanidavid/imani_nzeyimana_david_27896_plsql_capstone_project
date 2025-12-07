-- 1. Show latest audit events
SELECT
  audit_id,
  object_type,
  object_id,
  changed_on,
  changed_by,
  change_type,
  old_value,
  new_value
FROM AUDIT_LOG
ORDER BY audit_id DESC;

-- 2. Count audit events per object type
SELECT object_type, COUNT(*) AS audit_count
FROM AUDIT_LOG
GROUP BY object_type
ORDER BY audit_count DESC;

-- 3. Find changes made by a specific user
SELECT *
FROM AUDIT_LOG
WHERE changed_by = UPPER(:username)
ORDER BY changed_on DESC;

-- 4. Check update history for a product
SELECT *
FROM AUDIT_LOG
WHERE object_type = 'PRODUCT'
  AND object_id = :product_id
ORDER BY changed_on DESC;

-- 5. Failed insert attempts (weekdays/holidays trigger)
SELECT *
FROM AUDIT_LOG
WHERE change_type = 'BLOCKED_INSERT'
ORDER BY changed_on DESC;

-- 6. All actions on SALES_LINE
SELECT *
FROM AUDIT_LOG
WHERE object_type = 'SALES_LINE'
ORDER BY audit_id DESC;
