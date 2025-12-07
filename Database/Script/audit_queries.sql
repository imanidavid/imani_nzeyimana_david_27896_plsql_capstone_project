-- AUDIT TEST: weekday blocking trigger, weekend allowed inserts, holiday blocking and audit log entries captured

SET SERVEROUTPUT ON;

PROMPT == 1. CHECK CURRENT DAY TYPE ==

SELECT
    TO_CHAR(SYSDATE, 'DAY') AS current_day,
    TO_CHAR(SYSDATE, 'DY')  AS short_day
FROM dual;


-- 2. TEST WEEKDAY BLOCK (should FAIL with error)
PROMPT == TEST: WEEKDAY INSERT SHOULD BE BLOCKED ==

BEGIN
  INSERT INTO PRODUCT (product_id, sku, name, category, cost_price, list_price, active)
  VALUES (9999, 'TEST-BLOCK', 'Blocked Insert', 'Test', 1000, 2000, 'Y');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('EXPECTED ERROR: ' || SQLERRM);
END;
/


-- 3. TEST WEEKEND ALLOWED INSERT
PROMPT == TEST: WEEKEND INSERT SHOULD BE ALLOWED ==

BEGIN
  INSERT INTO PRODUCT (product_id, sku, name, category, cost_price, list_price, active)
  VALUES (9998, 'TEST-ALLOW', 'Weekend Insert', 'Test', 900, 1500, 'Y');
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Weekend insert SUCCESS.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Weekend insert FAILED: ' || SQLERRM);
END;
/


-- 4. TEST HOLIDAY BLOCK 
PROMPT == TEST: HOLIDAY INSERT SHOULD BE BLOCKED ==

BEGIN
  INSERT INTO PRODUCT (product_id, sku, name, category, cost_price, list_price, active)
  VALUES (9997, 'TEST-HOL', 'Holiday Insert', 'Test', 1000, 2000, 'Y');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('EXPECTED HOLIDAY BLOCK: ' || SQLERRM);
END;
/

-- 5. CHECK AUDIT LOG CONTENT
PROMPT == AUDIT LOG ENTRIES ==

SELECT audit_id,
       object_type,
       object_id,
       change_type,
       changed_by,
       changed_on,
       old_value,
       new_value
FROM AUDIT_LOG
ORDER BY audit_id DESC
FETCH FIRST 20 ROWS ONLY;
/

PROMPT == END OF AUDIT TEST ==
