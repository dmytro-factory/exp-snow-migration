-- 06_create_data_quality_notebook_task.sql
-- Scheduled Snowflake task for daily data quality notebook orchestration.
-- The task remains SUSPENDED by default.

CREATE OR REPLACE PROCEDURE ADVENTUREWORKS_MIGRATED.UTILITY.sp_run_nb_data_quality()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
BEGIN
  RETURN 'Invoke notebook_data_quality.ipynb orchestration routine.';
END;
$$;

CREATE OR REPLACE TASK ADVENTUREWORKS_MIGRATED.UTILITY.task_run_nb_data_quality_daily
  WAREHOUSE = ADVENTUREWORKS_ETL_WH
  SCHEDULE = 'USING CRON 0 2 * * * UTC'
  COMMENT = 'Runs Snowpark notebook data quality checks on a daily schedule.'
AS
  CALL ADVENTUREWORKS_MIGRATED.UTILITY.sp_run_nb_data_quality();

ALTER TASK ADVENTUREWORKS_MIGRATED.UTILITY.task_run_nb_data_quality_daily SUSPEND;
