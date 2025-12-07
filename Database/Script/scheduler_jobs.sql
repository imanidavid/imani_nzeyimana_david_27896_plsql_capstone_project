-- run this in MON_27896_DAVID_PROFITMARGIN_DB as SYS / SYSDBA

GRANT CREATE JOB TO margin_user;

-- Refresh margin baselines once per day
-- Runs MARGIN_MON_PKG.REFRESH_BASELINES at 02:00 every day

  DBMS_SCHEDULER.CREATE_JOB (
    job_name        => 'JOB_REFRESH_MARGIN_BASELINES',
    job_type        => 'STORED_PROCEDURE',
    job_action      => 'MARGIN_MON_PKG.REFRESH_BASELINES',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=DAILY;BYHOUR=2;BYMINUTE=0;BYSECOND=0',
    enabled         => TRUE,
    comments        => 'Recompute margin baselines once per night.'
  );
END;
/


-- test for Scheduler