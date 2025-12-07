
CREATE OR REPLACE TRIGGER trg_sales_line_access
BEFORE INSERT ON SALES_LINE
FOR EACH ROW
DECLARE
  v_today       DATE        := TRUNC(SYSDATE);
  v_day3        VARCHAR2(3);
  v_is_holiday  NUMBER;
  v_change_type VARCHAR2(50);
  v_message     VARCHAR2(400);
BEGIN
  -- Get day abbreviation MON/TUE/... with English NLS
  v_day3 := UPPER(
              TO_CHAR(
                v_today,
                'DY',
                'NLS_DATE_LANGUAGE=ENGLISH'
              )
            );

  -- Check if today is a holiday
  SELECT COUNT(*)
  INTO  v_is_holiday
  FROM  HOLIDAY_CALENDAR
  WHERE holiday_date = v_today;

  IF v_is_holiday > 0 THEN
    v_change_type := 'ACCESS_DENIED';
    v_message     := 'DENIED: Insert blocked on HOLIDAY';

    INSERT INTO AUDIT_LOG (
      audit_id,
      object_type,
      object_id,
      changed_on,
      changed_by,
      change_type,
      old_value,
      new_value
    )
    VALUES (
      seq_audit_log.NEXTVAL,
      'SALES_LINE_ACCESS',
      NVL(:NEW.order_id, -1),
      SYSDATE,
      USER,
      v_change_type,
      NULL,
      v_message
    );

    RAISE_APPLICATION_ERROR(-20021,
      'Insert into SALES_LINE is not allowed on holidays.');

  ELSIF v_day3 NOT IN ('SAT', 'SUN') THEN
    -- Weekday (Mon–Fri) – block
    v_change_type := 'ACCESS_DENIED';
    v_message     := 'DENIED: Insert blocked on WEEKDAY (' || v_day3 || ')';

    INSERT INTO AUDIT_LOG (
      audit_id,
      object_type,
      object_id,
      changed_on,
      changed_by,
      change_type,
      old_value,
      new_value
    )
    VALUES (
      seq_audit_log.NEXTVAL,
      'SALES_LINE_ACCESS',
      NVL(:NEW.order_id, -1),
      SYSDATE,
      USER,
      v_change_type,
      NULL,
      v_message
    );

    RAISE_APPLICATION_ERROR(-20022,
      'Insert into SALES_LINE is only allowed on weekends.');

  ELSE
    -- Weekend (Sat/Sun) – allow but still log
    v_change_type := 'ACCESS_ALLOWED';
    v_message     := 'ALLOWED: Weekend insert for order ' || NVL(:NEW.order_id,-1);

    INSERT INTO AUDIT_LOG (
      audit_id,
      object_type,
      object_id,
      changed_on,
      changed_by,
      change_type,
      old_value,
      new_value
    )
    VALUES (
      seq_audit_log.NEXTVAL,
      'SALES_LINE_ACCESS',
      NVL(:NEW.order_id, -1),
      SYSDATE,
      USER,
      v_change_type,
      NULL,
      v_message
    );
  END IF;
END;
/
