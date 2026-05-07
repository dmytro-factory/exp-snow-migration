-- validation_schema.sql
-- Validates that required Snowflake objects for the migration exist.

USE DATABASE ADVENTUREWORKS_MIGRATED;

CREATE OR REPLACE TEMP TABLE validation_schema_results (
  object_type STRING,
  object_name STRING,
  status STRING
);

INSERT INTO validation_schema_results
SELECT 'SCHEMA' AS object_type,
       e.schema_name AS object_name,
       IFF(a.schema_name IS NOT NULL, 'PASS', 'FAIL') AS status
FROM (
  SELECT 'STAGING' AS schema_name
  UNION ALL SELECT 'DW'
  UNION ALL SELECT 'UTILITY'
) e
LEFT JOIN (
  SELECT UPPER(SCHEMA_NAME) AS schema_name
  FROM ADVENTUREWORKS_MIGRATED.INFORMATION_SCHEMA.SCHEMATA
) a
  ON a.schema_name = e.schema_name;

INSERT INTO validation_schema_results
SELECT 'TABLE' AS object_type,
       e.schema_name || '.' || e.table_name AS object_name,
       IFF(a.table_name IS NOT NULL, 'PASS', 'FAIL') AS status
FROM (
  SELECT 'STAGING' AS schema_name, 'adventure_works_dw_build_version_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'database_log_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'dim_account_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'dim_currency_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'dim_customer_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'dim_date_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'dim_department_group_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'dim_employee_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'dim_geography_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'dim_organization_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'dim_product_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'dim_product_category_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'dim_product_subcategory_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'dim_promotion_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'dim_reseller_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'dim_sales_reason_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'dim_sales_territory_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'dim_scenario_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'fact_additional_international_product_description_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'fact_call_center_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'fact_currency_rate_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'fact_finance_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'fact_internet_sales_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'fact_internet_sales_reason_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'fact_product_inventory_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'fact_reseller_sales_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'fact_sales_quota_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'fact_survey_response_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'new_fact_currency_rate_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'prospective_buyer_stg' AS table_name
  UNION ALL SELECT 'STAGING' AS schema_name, 'sysdiagrams_stg' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'dim_account' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'dim_currency' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'dim_customer' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'dim_date' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'dim_department_group' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'dim_employee' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'dim_geography' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'dim_organization' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'dim_product' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'dim_product_category' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'dim_product_subcategory' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'dim_promotion' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'dim_reseller' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'dim_sales_reason' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'dim_sales_territory' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'dim_scenario' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'fact_additional_international_product_description' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'fact_call_center' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'fact_currency_rate' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'fact_finance' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'fact_internet_sales' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'fact_internet_sales_reason' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'fact_product_inventory' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'fact_reseller_sales' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'fact_sales_quota' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'fact_survey_response' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'fact_currency_rate_incremental' AS table_name
  UNION ALL SELECT 'DW' AS schema_name, 'dim_prospective_buyer' AS table_name
) e
LEFT JOIN (
  SELECT UPPER(TABLE_SCHEMA) AS schema_name, UPPER(TABLE_NAME) AS table_name
  FROM ADVENTUREWORKS_MIGRATED.INFORMATION_SCHEMA.TABLES
  WHERE TABLE_TYPE = 'BASE TABLE'
) a
  ON a.schema_name = e.schema_name
 AND a.table_name = UPPER(e.table_name);

SHOW FILE FORMATS IN SCHEMA ADVENTUREWORKS_MIGRATED.UTILITY;
CREATE OR REPLACE TEMP TABLE actual_file_formats AS
SELECT UPPER("name") AS object_name
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

SHOW STAGES IN SCHEMA ADVENTUREWORKS_MIGRATED.STAGING;
CREATE OR REPLACE TEMP TABLE actual_stages AS
SELECT UPPER("name") AS object_name
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

SHOW USER PROCEDURES IN SCHEMA ADVENTUREWORKS_MIGRATED.UTILITY;
CREATE OR REPLACE TEMP TABLE actual_procedures AS
SELECT UPPER("name") AS object_name
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

SHOW TASKS IN SCHEMA ADVENTUREWORKS_MIGRATED.UTILITY;
CREATE OR REPLACE TEMP TABLE actual_tasks AS
SELECT UPPER("name") AS object_name
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

INSERT INTO validation_schema_results
SELECT u.object_type,
       'UTILITY.' || u.object_name AS object_name,
       CASE
         WHEN u.object_type = 'FILE_FORMAT' THEN IFF(ff.object_name IS NOT NULL, 'PASS', 'FAIL')
         WHEN u.object_type = 'STAGE' THEN IFF(st.object_name IS NOT NULL, 'PASS', 'FAIL')
         WHEN u.object_type = 'PROCEDURE' THEN IFF(pr.object_name IS NOT NULL, 'PASS', 'FAIL')
         WHEN u.object_type = 'TASK' THEN IFF(ts.object_name IS NOT NULL, 'PASS', 'FAIL')
         ELSE 'FAIL'
       END AS status
FROM (
  SELECT 'FILE_FORMAT' AS object_type, 'FF_CSV' AS object_name
  UNION ALL SELECT 'FILE_FORMAT', 'FF_PARQUET'
  UNION ALL SELECT 'STAGE', 'PARQUET_INTERNAL_STAGE'
  UNION ALL SELECT 'PROCEDURE', 'SP_RUN_NB_DATA_QUALITY'
  UNION ALL SELECT 'TASK', 'TASK_RUN_NB_DATA_QUALITY_DAILY'
) u
LEFT JOIN actual_file_formats ff
  ON u.object_type = 'FILE_FORMAT'
 AND ff.object_name = u.object_name
LEFT JOIN actual_stages st
  ON u.object_type = 'STAGE'
 AND st.object_name = u.object_name
LEFT JOIN actual_procedures pr
  ON u.object_type = 'PROCEDURE'
 AND pr.object_name = u.object_name
LEFT JOIN actual_tasks ts
  ON u.object_type = 'TASK'
 AND ts.object_name = u.object_name;

SELECT object_type, object_name, status
FROM validation_schema_results
ORDER BY object_type, object_name;

SELECT IFF(COUNT_IF(status = 'FAIL') = 0, 'PASS', 'FAIL') AS overall_status,
       COUNT_IF(status = 'FAIL') AS failed_objects,
       COUNT(*) AS checked_objects
FROM validation_schema_results;
