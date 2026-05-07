-- validation_scd_type2.sql
-- Validates SCD Type 2 integrity in DW dimension tables.

USE DATABASE ADVENTUREWORKS_MIGRATED;

CREATE OR REPLACE TEMP TABLE validation_scd_type2_results AS
WITH checks AS (
  SELECT 'current_row_per_business_key' AS check_name,
         'dim_account' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "ACCOUNTKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_account
    GROUP BY "ACCOUNTKEY"
    HAVING SUM(IFF("_IS_CURRENT", 1, 0)) <> 1
  ) anomalies
  UNION ALL
  SELECT 'current_rows_have_open_valid_to' AS check_name,
         'dim_account' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_account
  WHERE "_IS_CURRENT" = TRUE
    AND "_VALID_TO" IS NOT NULL
  UNION ALL
  SELECT 'expired_rows_have_valid_to' AS check_name,
         'dim_account' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_account
  WHERE "_IS_CURRENT" = FALSE
    AND "_VALID_TO" IS NULL
  UNION ALL
  SELECT 'no_overlapping_periods' AS check_name,
         'dim_account' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "ACCOUNTKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "ACCOUNTKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_account
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND COALESCE("_VALID_TO", next_valid_from) > next_valid_from
  UNION ALL
  SELECT 'no_gaps_between_periods' AS check_name,
         'dim_account' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "ACCOUNTKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "ACCOUNTKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_account
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND "_VALID_TO" IS NOT NULL
    AND DATEDIFF('second', "_VALID_TO", next_valid_from) > 1
  UNION ALL
  SELECT 'source_key_has_current_record' AS check_name,
         'dim_account' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT DISTINCT "ACCOUNTKEY"
    FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_account_stg
    WHERE "ACCOUNTKEY" IS NOT NULL
    MINUS
    SELECT DISTINCT "ACCOUNTKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_account
    WHERE "_IS_CURRENT" = TRUE
      AND "ACCOUNTKEY" IS NOT NULL
  ) missing_keys
  UNION ALL
  SELECT 'current_row_per_business_key' AS check_name,
         'dim_currency' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "CURRENCYKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_currency
    GROUP BY "CURRENCYKEY"
    HAVING SUM(IFF("_IS_CURRENT", 1, 0)) <> 1
  ) anomalies
  UNION ALL
  SELECT 'current_rows_have_open_valid_to' AS check_name,
         'dim_currency' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_currency
  WHERE "_IS_CURRENT" = TRUE
    AND "_VALID_TO" IS NOT NULL
  UNION ALL
  SELECT 'expired_rows_have_valid_to' AS check_name,
         'dim_currency' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_currency
  WHERE "_IS_CURRENT" = FALSE
    AND "_VALID_TO" IS NULL
  UNION ALL
  SELECT 'no_overlapping_periods' AS check_name,
         'dim_currency' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "CURRENCYKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "CURRENCYKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_currency
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND COALESCE("_VALID_TO", next_valid_from) > next_valid_from
  UNION ALL
  SELECT 'no_gaps_between_periods' AS check_name,
         'dim_currency' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "CURRENCYKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "CURRENCYKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_currency
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND "_VALID_TO" IS NOT NULL
    AND DATEDIFF('second', "_VALID_TO", next_valid_from) > 1
  UNION ALL
  SELECT 'source_key_has_current_record' AS check_name,
         'dim_currency' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT DISTINCT "CURRENCYKEY"
    FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_currency_stg
    WHERE "CURRENCYKEY" IS NOT NULL
    MINUS
    SELECT DISTINCT "CURRENCYKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_currency
    WHERE "_IS_CURRENT" = TRUE
      AND "CURRENCYKEY" IS NOT NULL
  ) missing_keys
  UNION ALL
  SELECT 'current_row_per_business_key' AS check_name,
         'dim_customer' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "CUSTOMERKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_customer
    GROUP BY "CUSTOMERKEY"
    HAVING SUM(IFF("_IS_CURRENT", 1, 0)) <> 1
  ) anomalies
  UNION ALL
  SELECT 'current_rows_have_open_valid_to' AS check_name,
         'dim_customer' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_customer
  WHERE "_IS_CURRENT" = TRUE
    AND "_VALID_TO" IS NOT NULL
  UNION ALL
  SELECT 'expired_rows_have_valid_to' AS check_name,
         'dim_customer' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_customer
  WHERE "_IS_CURRENT" = FALSE
    AND "_VALID_TO" IS NULL
  UNION ALL
  SELECT 'no_overlapping_periods' AS check_name,
         'dim_customer' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "CUSTOMERKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "CUSTOMERKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_customer
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND COALESCE("_VALID_TO", next_valid_from) > next_valid_from
  UNION ALL
  SELECT 'no_gaps_between_periods' AS check_name,
         'dim_customer' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "CUSTOMERKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "CUSTOMERKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_customer
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND "_VALID_TO" IS NOT NULL
    AND DATEDIFF('second', "_VALID_TO", next_valid_from) > 1
  UNION ALL
  SELECT 'source_key_has_current_record' AS check_name,
         'dim_customer' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT DISTINCT "CUSTOMERKEY"
    FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_customer_stg
    WHERE "CUSTOMERKEY" IS NOT NULL
    MINUS
    SELECT DISTINCT "CUSTOMERKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_customer
    WHERE "_IS_CURRENT" = TRUE
      AND "CUSTOMERKEY" IS NOT NULL
  ) missing_keys
  UNION ALL
  SELECT 'current_row_per_business_key' AS check_name,
         'dim_date' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "DATEKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_date
    GROUP BY "DATEKEY"
    HAVING SUM(IFF("_IS_CURRENT", 1, 0)) <> 1
  ) anomalies
  UNION ALL
  SELECT 'current_rows_have_open_valid_to' AS check_name,
         'dim_date' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_date
  WHERE "_IS_CURRENT" = TRUE
    AND "_VALID_TO" IS NOT NULL
  UNION ALL
  SELECT 'expired_rows_have_valid_to' AS check_name,
         'dim_date' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_date
  WHERE "_IS_CURRENT" = FALSE
    AND "_VALID_TO" IS NULL
  UNION ALL
  SELECT 'no_overlapping_periods' AS check_name,
         'dim_date' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "DATEKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "DATEKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_date
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND COALESCE("_VALID_TO", next_valid_from) > next_valid_from
  UNION ALL
  SELECT 'no_gaps_between_periods' AS check_name,
         'dim_date' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "DATEKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "DATEKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_date
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND "_VALID_TO" IS NOT NULL
    AND DATEDIFF('second', "_VALID_TO", next_valid_from) > 1
  UNION ALL
  SELECT 'source_key_has_current_record' AS check_name,
         'dim_date' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT DISTINCT "DATEKEY"
    FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_date_stg
    WHERE "DATEKEY" IS NOT NULL
    MINUS
    SELECT DISTINCT "DATEKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_date
    WHERE "_IS_CURRENT" = TRUE
      AND "DATEKEY" IS NOT NULL
  ) missing_keys
  UNION ALL
  SELECT 'current_row_per_business_key' AS check_name,
         'dim_department_group' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "DEPARTMENTGROUPKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_department_group
    GROUP BY "DEPARTMENTGROUPKEY"
    HAVING SUM(IFF("_IS_CURRENT", 1, 0)) <> 1
  ) anomalies
  UNION ALL
  SELECT 'current_rows_have_open_valid_to' AS check_name,
         'dim_department_group' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_department_group
  WHERE "_IS_CURRENT" = TRUE
    AND "_VALID_TO" IS NOT NULL
  UNION ALL
  SELECT 'expired_rows_have_valid_to' AS check_name,
         'dim_department_group' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_department_group
  WHERE "_IS_CURRENT" = FALSE
    AND "_VALID_TO" IS NULL
  UNION ALL
  SELECT 'no_overlapping_periods' AS check_name,
         'dim_department_group' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "DEPARTMENTGROUPKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "DEPARTMENTGROUPKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_department_group
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND COALESCE("_VALID_TO", next_valid_from) > next_valid_from
  UNION ALL
  SELECT 'no_gaps_between_periods' AS check_name,
         'dim_department_group' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "DEPARTMENTGROUPKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "DEPARTMENTGROUPKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_department_group
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND "_VALID_TO" IS NOT NULL
    AND DATEDIFF('second', "_VALID_TO", next_valid_from) > 1
  UNION ALL
  SELECT 'source_key_has_current_record' AS check_name,
         'dim_department_group' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT DISTINCT "DEPARTMENTGROUPKEY"
    FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_department_group_stg
    WHERE "DEPARTMENTGROUPKEY" IS NOT NULL
    MINUS
    SELECT DISTINCT "DEPARTMENTGROUPKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_department_group
    WHERE "_IS_CURRENT" = TRUE
      AND "DEPARTMENTGROUPKEY" IS NOT NULL
  ) missing_keys
  UNION ALL
  SELECT 'current_row_per_business_key' AS check_name,
         'dim_employee' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "EMPLOYEEKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_employee
    GROUP BY "EMPLOYEEKEY"
    HAVING SUM(IFF("_IS_CURRENT", 1, 0)) <> 1
  ) anomalies
  UNION ALL
  SELECT 'current_rows_have_open_valid_to' AS check_name,
         'dim_employee' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_employee
  WHERE "_IS_CURRENT" = TRUE
    AND "_VALID_TO" IS NOT NULL
  UNION ALL
  SELECT 'expired_rows_have_valid_to' AS check_name,
         'dim_employee' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_employee
  WHERE "_IS_CURRENT" = FALSE
    AND "_VALID_TO" IS NULL
  UNION ALL
  SELECT 'no_overlapping_periods' AS check_name,
         'dim_employee' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "EMPLOYEEKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "EMPLOYEEKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_employee
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND COALESCE("_VALID_TO", next_valid_from) > next_valid_from
  UNION ALL
  SELECT 'no_gaps_between_periods' AS check_name,
         'dim_employee' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "EMPLOYEEKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "EMPLOYEEKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_employee
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND "_VALID_TO" IS NOT NULL
    AND DATEDIFF('second', "_VALID_TO", next_valid_from) > 1
  UNION ALL
  SELECT 'source_key_has_current_record' AS check_name,
         'dim_employee' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT DISTINCT "EMPLOYEEKEY"
    FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_employee_stg
    WHERE "EMPLOYEEKEY" IS NOT NULL
    MINUS
    SELECT DISTINCT "EMPLOYEEKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_employee
    WHERE "_IS_CURRENT" = TRUE
      AND "EMPLOYEEKEY" IS NOT NULL
  ) missing_keys
  UNION ALL
  SELECT 'current_row_per_business_key' AS check_name,
         'dim_geography' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "GEOGRAPHYKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_geography
    GROUP BY "GEOGRAPHYKEY"
    HAVING SUM(IFF("_IS_CURRENT", 1, 0)) <> 1
  ) anomalies
  UNION ALL
  SELECT 'current_rows_have_open_valid_to' AS check_name,
         'dim_geography' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_geography
  WHERE "_IS_CURRENT" = TRUE
    AND "_VALID_TO" IS NOT NULL
  UNION ALL
  SELECT 'expired_rows_have_valid_to' AS check_name,
         'dim_geography' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_geography
  WHERE "_IS_CURRENT" = FALSE
    AND "_VALID_TO" IS NULL
  UNION ALL
  SELECT 'no_overlapping_periods' AS check_name,
         'dim_geography' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "GEOGRAPHYKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "GEOGRAPHYKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_geography
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND COALESCE("_VALID_TO", next_valid_from) > next_valid_from
  UNION ALL
  SELECT 'no_gaps_between_periods' AS check_name,
         'dim_geography' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "GEOGRAPHYKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "GEOGRAPHYKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_geography
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND "_VALID_TO" IS NOT NULL
    AND DATEDIFF('second', "_VALID_TO", next_valid_from) > 1
  UNION ALL
  SELECT 'source_key_has_current_record' AS check_name,
         'dim_geography' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT DISTINCT "GEOGRAPHYKEY"
    FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_geography_stg
    WHERE "GEOGRAPHYKEY" IS NOT NULL
    MINUS
    SELECT DISTINCT "GEOGRAPHYKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_geography
    WHERE "_IS_CURRENT" = TRUE
      AND "GEOGRAPHYKEY" IS NOT NULL
  ) missing_keys
  UNION ALL
  SELECT 'current_row_per_business_key' AS check_name,
         'dim_organization' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "ORGANIZATIONKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_organization
    GROUP BY "ORGANIZATIONKEY"
    HAVING SUM(IFF("_IS_CURRENT", 1, 0)) <> 1
  ) anomalies
  UNION ALL
  SELECT 'current_rows_have_open_valid_to' AS check_name,
         'dim_organization' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_organization
  WHERE "_IS_CURRENT" = TRUE
    AND "_VALID_TO" IS NOT NULL
  UNION ALL
  SELECT 'expired_rows_have_valid_to' AS check_name,
         'dim_organization' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_organization
  WHERE "_IS_CURRENT" = FALSE
    AND "_VALID_TO" IS NULL
  UNION ALL
  SELECT 'no_overlapping_periods' AS check_name,
         'dim_organization' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "ORGANIZATIONKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "ORGANIZATIONKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_organization
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND COALESCE("_VALID_TO", next_valid_from) > next_valid_from
  UNION ALL
  SELECT 'no_gaps_between_periods' AS check_name,
         'dim_organization' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "ORGANIZATIONKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "ORGANIZATIONKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_organization
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND "_VALID_TO" IS NOT NULL
    AND DATEDIFF('second', "_VALID_TO", next_valid_from) > 1
  UNION ALL
  SELECT 'source_key_has_current_record' AS check_name,
         'dim_organization' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT DISTINCT "ORGANIZATIONKEY"
    FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_organization_stg
    WHERE "ORGANIZATIONKEY" IS NOT NULL
    MINUS
    SELECT DISTINCT "ORGANIZATIONKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_organization
    WHERE "_IS_CURRENT" = TRUE
      AND "ORGANIZATIONKEY" IS NOT NULL
  ) missing_keys
  UNION ALL
  SELECT 'current_row_per_business_key' AS check_name,
         'dim_product' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "PRODUCTKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_product
    GROUP BY "PRODUCTKEY"
    HAVING SUM(IFF("_IS_CURRENT", 1, 0)) <> 1
  ) anomalies
  UNION ALL
  SELECT 'current_rows_have_open_valid_to' AS check_name,
         'dim_product' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_product
  WHERE "_IS_CURRENT" = TRUE
    AND "_VALID_TO" IS NOT NULL
  UNION ALL
  SELECT 'expired_rows_have_valid_to' AS check_name,
         'dim_product' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_product
  WHERE "_IS_CURRENT" = FALSE
    AND "_VALID_TO" IS NULL
  UNION ALL
  SELECT 'no_overlapping_periods' AS check_name,
         'dim_product' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "PRODUCTKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "PRODUCTKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_product
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND COALESCE("_VALID_TO", next_valid_from) > next_valid_from
  UNION ALL
  SELECT 'no_gaps_between_periods' AS check_name,
         'dim_product' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "PRODUCTKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "PRODUCTKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_product
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND "_VALID_TO" IS NOT NULL
    AND DATEDIFF('second', "_VALID_TO", next_valid_from) > 1
  UNION ALL
  SELECT 'source_key_has_current_record' AS check_name,
         'dim_product' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT DISTINCT "PRODUCTKEY"
    FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_product_stg
    WHERE "PRODUCTKEY" IS NOT NULL
    MINUS
    SELECT DISTINCT "PRODUCTKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_product
    WHERE "_IS_CURRENT" = TRUE
      AND "PRODUCTKEY" IS NOT NULL
  ) missing_keys
  UNION ALL
  SELECT 'current_row_per_business_key' AS check_name,
         'dim_product_category' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "PRODUCTCATEGORYKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_product_category
    GROUP BY "PRODUCTCATEGORYKEY"
    HAVING SUM(IFF("_IS_CURRENT", 1, 0)) <> 1
  ) anomalies
  UNION ALL
  SELECT 'current_rows_have_open_valid_to' AS check_name,
         'dim_product_category' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_product_category
  WHERE "_IS_CURRENT" = TRUE
    AND "_VALID_TO" IS NOT NULL
  UNION ALL
  SELECT 'expired_rows_have_valid_to' AS check_name,
         'dim_product_category' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_product_category
  WHERE "_IS_CURRENT" = FALSE
    AND "_VALID_TO" IS NULL
  UNION ALL
  SELECT 'no_overlapping_periods' AS check_name,
         'dim_product_category' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "PRODUCTCATEGORYKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "PRODUCTCATEGORYKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_product_category
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND COALESCE("_VALID_TO", next_valid_from) > next_valid_from
  UNION ALL
  SELECT 'no_gaps_between_periods' AS check_name,
         'dim_product_category' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "PRODUCTCATEGORYKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "PRODUCTCATEGORYKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_product_category
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND "_VALID_TO" IS NOT NULL
    AND DATEDIFF('second', "_VALID_TO", next_valid_from) > 1
  UNION ALL
  SELECT 'source_key_has_current_record' AS check_name,
         'dim_product_category' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT DISTINCT "PRODUCTCATEGORYKEY"
    FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_product_category_stg
    WHERE "PRODUCTCATEGORYKEY" IS NOT NULL
    MINUS
    SELECT DISTINCT "PRODUCTCATEGORYKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_product_category
    WHERE "_IS_CURRENT" = TRUE
      AND "PRODUCTCATEGORYKEY" IS NOT NULL
  ) missing_keys
  UNION ALL
  SELECT 'current_row_per_business_key' AS check_name,
         'dim_product_subcategory' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "PRODUCTSUBCATEGORYKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_product_subcategory
    GROUP BY "PRODUCTSUBCATEGORYKEY"
    HAVING SUM(IFF("_IS_CURRENT", 1, 0)) <> 1
  ) anomalies
  UNION ALL
  SELECT 'current_rows_have_open_valid_to' AS check_name,
         'dim_product_subcategory' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_product_subcategory
  WHERE "_IS_CURRENT" = TRUE
    AND "_VALID_TO" IS NOT NULL
  UNION ALL
  SELECT 'expired_rows_have_valid_to' AS check_name,
         'dim_product_subcategory' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_product_subcategory
  WHERE "_IS_CURRENT" = FALSE
    AND "_VALID_TO" IS NULL
  UNION ALL
  SELECT 'no_overlapping_periods' AS check_name,
         'dim_product_subcategory' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "PRODUCTSUBCATEGORYKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "PRODUCTSUBCATEGORYKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_product_subcategory
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND COALESCE("_VALID_TO", next_valid_from) > next_valid_from
  UNION ALL
  SELECT 'no_gaps_between_periods' AS check_name,
         'dim_product_subcategory' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "PRODUCTSUBCATEGORYKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "PRODUCTSUBCATEGORYKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_product_subcategory
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND "_VALID_TO" IS NOT NULL
    AND DATEDIFF('second', "_VALID_TO", next_valid_from) > 1
  UNION ALL
  SELECT 'source_key_has_current_record' AS check_name,
         'dim_product_subcategory' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT DISTINCT "PRODUCTSUBCATEGORYKEY"
    FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_product_subcategory_stg
    WHERE "PRODUCTSUBCATEGORYKEY" IS NOT NULL
    MINUS
    SELECT DISTINCT "PRODUCTSUBCATEGORYKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_product_subcategory
    WHERE "_IS_CURRENT" = TRUE
      AND "PRODUCTSUBCATEGORYKEY" IS NOT NULL
  ) missing_keys
  UNION ALL
  SELECT 'current_row_per_business_key' AS check_name,
         'dim_promotion' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "PROMOTIONKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_promotion
    GROUP BY "PROMOTIONKEY"
    HAVING SUM(IFF("_IS_CURRENT", 1, 0)) <> 1
  ) anomalies
  UNION ALL
  SELECT 'current_rows_have_open_valid_to' AS check_name,
         'dim_promotion' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_promotion
  WHERE "_IS_CURRENT" = TRUE
    AND "_VALID_TO" IS NOT NULL
  UNION ALL
  SELECT 'expired_rows_have_valid_to' AS check_name,
         'dim_promotion' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_promotion
  WHERE "_IS_CURRENT" = FALSE
    AND "_VALID_TO" IS NULL
  UNION ALL
  SELECT 'no_overlapping_periods' AS check_name,
         'dim_promotion' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "PROMOTIONKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "PROMOTIONKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_promotion
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND COALESCE("_VALID_TO", next_valid_from) > next_valid_from
  UNION ALL
  SELECT 'no_gaps_between_periods' AS check_name,
         'dim_promotion' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "PROMOTIONKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "PROMOTIONKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_promotion
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND "_VALID_TO" IS NOT NULL
    AND DATEDIFF('second', "_VALID_TO", next_valid_from) > 1
  UNION ALL
  SELECT 'source_key_has_current_record' AS check_name,
         'dim_promotion' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT DISTINCT "PROMOTIONKEY"
    FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_promotion_stg
    WHERE "PROMOTIONKEY" IS NOT NULL
    MINUS
    SELECT DISTINCT "PROMOTIONKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_promotion
    WHERE "_IS_CURRENT" = TRUE
      AND "PROMOTIONKEY" IS NOT NULL
  ) missing_keys
  UNION ALL
  SELECT 'current_row_per_business_key' AS check_name,
         'dim_reseller' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "RESELLERKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_reseller
    GROUP BY "RESELLERKEY"
    HAVING SUM(IFF("_IS_CURRENT", 1, 0)) <> 1
  ) anomalies
  UNION ALL
  SELECT 'current_rows_have_open_valid_to' AS check_name,
         'dim_reseller' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_reseller
  WHERE "_IS_CURRENT" = TRUE
    AND "_VALID_TO" IS NOT NULL
  UNION ALL
  SELECT 'expired_rows_have_valid_to' AS check_name,
         'dim_reseller' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_reseller
  WHERE "_IS_CURRENT" = FALSE
    AND "_VALID_TO" IS NULL
  UNION ALL
  SELECT 'no_overlapping_periods' AS check_name,
         'dim_reseller' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "RESELLERKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "RESELLERKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_reseller
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND COALESCE("_VALID_TO", next_valid_from) > next_valid_from
  UNION ALL
  SELECT 'no_gaps_between_periods' AS check_name,
         'dim_reseller' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "RESELLERKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "RESELLERKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_reseller
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND "_VALID_TO" IS NOT NULL
    AND DATEDIFF('second', "_VALID_TO", next_valid_from) > 1
  UNION ALL
  SELECT 'source_key_has_current_record' AS check_name,
         'dim_reseller' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT DISTINCT "RESELLERKEY"
    FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_reseller_stg
    WHERE "RESELLERKEY" IS NOT NULL
    MINUS
    SELECT DISTINCT "RESELLERKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_reseller
    WHERE "_IS_CURRENT" = TRUE
      AND "RESELLERKEY" IS NOT NULL
  ) missing_keys
  UNION ALL
  SELECT 'current_row_per_business_key' AS check_name,
         'dim_sales_reason' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "SALESREASONKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_sales_reason
    GROUP BY "SALESREASONKEY"
    HAVING SUM(IFF("_IS_CURRENT", 1, 0)) <> 1
  ) anomalies
  UNION ALL
  SELECT 'current_rows_have_open_valid_to' AS check_name,
         'dim_sales_reason' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_sales_reason
  WHERE "_IS_CURRENT" = TRUE
    AND "_VALID_TO" IS NOT NULL
  UNION ALL
  SELECT 'expired_rows_have_valid_to' AS check_name,
         'dim_sales_reason' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_sales_reason
  WHERE "_IS_CURRENT" = FALSE
    AND "_VALID_TO" IS NULL
  UNION ALL
  SELECT 'no_overlapping_periods' AS check_name,
         'dim_sales_reason' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "SALESREASONKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "SALESREASONKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_sales_reason
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND COALESCE("_VALID_TO", next_valid_from) > next_valid_from
  UNION ALL
  SELECT 'no_gaps_between_periods' AS check_name,
         'dim_sales_reason' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "SALESREASONKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "SALESREASONKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_sales_reason
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND "_VALID_TO" IS NOT NULL
    AND DATEDIFF('second', "_VALID_TO", next_valid_from) > 1
  UNION ALL
  SELECT 'source_key_has_current_record' AS check_name,
         'dim_sales_reason' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT DISTINCT "SALESREASONKEY"
    FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_sales_reason_stg
    WHERE "SALESREASONKEY" IS NOT NULL
    MINUS
    SELECT DISTINCT "SALESREASONKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_sales_reason
    WHERE "_IS_CURRENT" = TRUE
      AND "SALESREASONKEY" IS NOT NULL
  ) missing_keys
  UNION ALL
  SELECT 'current_row_per_business_key' AS check_name,
         'dim_sales_territory' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "SALESTERRITORYKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_sales_territory
    GROUP BY "SALESTERRITORYKEY"
    HAVING SUM(IFF("_IS_CURRENT", 1, 0)) <> 1
  ) anomalies
  UNION ALL
  SELECT 'current_rows_have_open_valid_to' AS check_name,
         'dim_sales_territory' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_sales_territory
  WHERE "_IS_CURRENT" = TRUE
    AND "_VALID_TO" IS NOT NULL
  UNION ALL
  SELECT 'expired_rows_have_valid_to' AS check_name,
         'dim_sales_territory' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_sales_territory
  WHERE "_IS_CURRENT" = FALSE
    AND "_VALID_TO" IS NULL
  UNION ALL
  SELECT 'no_overlapping_periods' AS check_name,
         'dim_sales_territory' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "SALESTERRITORYKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "SALESTERRITORYKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_sales_territory
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND COALESCE("_VALID_TO", next_valid_from) > next_valid_from
  UNION ALL
  SELECT 'no_gaps_between_periods' AS check_name,
         'dim_sales_territory' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "SALESTERRITORYKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "SALESTERRITORYKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_sales_territory
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND "_VALID_TO" IS NOT NULL
    AND DATEDIFF('second', "_VALID_TO", next_valid_from) > 1
  UNION ALL
  SELECT 'source_key_has_current_record' AS check_name,
         'dim_sales_territory' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT DISTINCT "SALESTERRITORYKEY"
    FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_sales_territory_stg
    WHERE "SALESTERRITORYKEY" IS NOT NULL
    MINUS
    SELECT DISTINCT "SALESTERRITORYKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_sales_territory
    WHERE "_IS_CURRENT" = TRUE
      AND "SALESTERRITORYKEY" IS NOT NULL
  ) missing_keys
  UNION ALL
  SELECT 'current_row_per_business_key' AS check_name,
         'dim_scenario' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "SCENARIOKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_scenario
    GROUP BY "SCENARIOKEY"
    HAVING SUM(IFF("_IS_CURRENT", 1, 0)) <> 1
  ) anomalies
  UNION ALL
  SELECT 'current_rows_have_open_valid_to' AS check_name,
         'dim_scenario' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_scenario
  WHERE "_IS_CURRENT" = TRUE
    AND "_VALID_TO" IS NOT NULL
  UNION ALL
  SELECT 'expired_rows_have_valid_to' AS check_name,
         'dim_scenario' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_scenario
  WHERE "_IS_CURRENT" = FALSE
    AND "_VALID_TO" IS NULL
  UNION ALL
  SELECT 'no_overlapping_periods' AS check_name,
         'dim_scenario' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "SCENARIOKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "SCENARIOKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_scenario
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND COALESCE("_VALID_TO", next_valid_from) > next_valid_from
  UNION ALL
  SELECT 'no_gaps_between_periods' AS check_name,
         'dim_scenario' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "SCENARIOKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "SCENARIOKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_scenario
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND "_VALID_TO" IS NOT NULL
    AND DATEDIFF('second', "_VALID_TO", next_valid_from) > 1
  UNION ALL
  SELECT 'source_key_has_current_record' AS check_name,
         'dim_scenario' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT DISTINCT "SCENARIOKEY"
    FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_scenario_stg
    WHERE "SCENARIOKEY" IS NOT NULL
    MINUS
    SELECT DISTINCT "SCENARIOKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_scenario
    WHERE "_IS_CURRENT" = TRUE
      AND "SCENARIOKEY" IS NOT NULL
  ) missing_keys
  UNION ALL
  SELECT 'current_row_per_business_key' AS check_name,
         'dim_prospective_buyer' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "PROSPECTIVEBUYERKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_prospective_buyer
    GROUP BY "PROSPECTIVEBUYERKEY"
    HAVING SUM(IFF("_IS_CURRENT", 1, 0)) <> 1
  ) anomalies
  UNION ALL
  SELECT 'current_rows_have_open_valid_to' AS check_name,
         'dim_prospective_buyer' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_prospective_buyer
  WHERE "_IS_CURRENT" = TRUE
    AND "_VALID_TO" IS NOT NULL
  UNION ALL
  SELECT 'expired_rows_have_valid_to' AS check_name,
         'dim_prospective_buyer' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_prospective_buyer
  WHERE "_IS_CURRENT" = FALSE
    AND "_VALID_TO" IS NULL
  UNION ALL
  SELECT 'no_overlapping_periods' AS check_name,
         'dim_prospective_buyer' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "PROSPECTIVEBUYERKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "PROSPECTIVEBUYERKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_prospective_buyer
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND COALESCE("_VALID_TO", next_valid_from) > next_valid_from
  UNION ALL
  SELECT 'no_gaps_between_periods' AS check_name,
         'dim_prospective_buyer' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT "PROSPECTIVEBUYERKEY",
           "_VALID_FROM",
           "_VALID_TO",
           LEAD("_VALID_FROM") OVER (PARTITION BY "PROSPECTIVEBUYERKEY" ORDER BY "_VALID_FROM", COALESCE("_VALID_TO", '9999-12-31'::TIMESTAMP_NTZ)) AS next_valid_from
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_prospective_buyer
  ) periods
  WHERE next_valid_from IS NOT NULL
    AND "_VALID_TO" IS NOT NULL
    AND DATEDIFF('second', "_VALID_TO", next_valid_from) > 1
  UNION ALL
  SELECT 'source_key_has_current_record' AS check_name,
         'dim_prospective_buyer' AS table_name,
         COUNT(*) AS failed_records,
         IFF(COUNT(*) = 0, 'PASS', 'FAIL') AS status
  FROM (
    SELECT DISTINCT "PROSPECTIVEBUYERKEY"
    FROM ADVENTUREWORKS_MIGRATED.STAGING.prospective_buyer_stg
    WHERE "PROSPECTIVEBUYERKEY" IS NOT NULL
    MINUS
    SELECT DISTINCT "PROSPECTIVEBUYERKEY"
    FROM ADVENTUREWORKS_MIGRATED.DW.dim_prospective_buyer
    WHERE "_IS_CURRENT" = TRUE
      AND "PROSPECTIVEBUYERKEY" IS NOT NULL
  ) missing_keys
)
SELECT check_name, table_name, failed_records, status
FROM checks;

SELECT check_name, table_name, failed_records, status
FROM validation_scd_type2_results
ORDER BY table_name, check_name;

SELECT IFF(COUNT_IF(status = 'FAIL') = 0, 'PASS', 'FAIL') AS overall_status,
       COUNT_IF(status = 'FAIL') AS failed_checks,
       COUNT(*) AS total_checks
FROM validation_scd_type2_results;
