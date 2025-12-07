BEGIN
  EXECUTE IMMEDIATE q'[
    CREATE SEQUENCE AUDIT_LOG_SEQ
      START WITH 1
      INCREMENT BY 1
      NOCACHE
  ]';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -955 THEN 
      RAISE;
    END IF;
END;
/

-- Audit package
CREATE OR REPLACE PACKAGE audit_pkg IS
  PROCEDURE log_change(
    p_object_type IN VARCHAR2,
    p_object_id   IN NUMBER,
    p_change_type IN VARCHAR2,
    p_old_value   IN VARCHAR2,
    p_new_value   IN VARCHAR2
  );
END audit_pkg;
/
SHOW ERRORS PACKAGE audit_pkg;

CREATE OR REPLACE PACKAGE BODY audit_pkg IS
  PROCEDURE log_change(
    p_object_type IN VARCHAR2,
    p_object_id   IN NUMBER,
    p_change_type IN VARCHAR2,
    p_old_value   IN VARCHAR2,
    p_new_value   IN VARCHAR2
  ) IS
    v_user VARCHAR2(50);
  BEGIN
    v_user := NVL(SYS_CONTEXT('USERENV','SESSION_USER'), USER);

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
      AUDIT_LOG_SEQ.NEXTVAL,
      p_object_type,
      p_object_id,
      SYSDATE,
      v_user,
      p_change_type,
      SUBSTR(p_old_value, 1, 4000),
      SUBSTR(p_new_value, 1, 4000)
    );
  END log_change;
END audit_pkg;
/
SHOW ERRORS PACKAGE BODY audit_pkg;
