-- validation_row_counts.sql
-- Compares SQL Server source snapshot row counts to Snowflake STAGING and DW row counts.

USE DATABASE ADVENTUREWORKS_MIGRATED;

CREATE OR REPLACE TEMP TABLE validation_row_count_results AS
WITH source_counts AS (
  SELECT 'dbo.AdventureWorksDWBuildVersion' AS source_table, 1 AS source_count
  UNION ALL SELECT 'dbo.DatabaseLog' AS source_table, 96 AS source_count
  UNION ALL SELECT 'dbo.DimAccount' AS source_table, 99 AS source_count
  UNION ALL SELECT 'dbo.DimCurrency' AS source_table, 105 AS source_count
  UNION ALL SELECT 'dbo.DimCustomer' AS source_table, 18484 AS source_count
  UNION ALL SELECT 'dbo.DimDate' AS source_table, 3652 AS source_count
  UNION ALL SELECT 'dbo.DimDepartmentGroup' AS source_table, 7 AS source_count
  UNION ALL SELECT 'dbo.DimEmployee' AS source_table, 296 AS source_count
  UNION ALL SELECT 'dbo.DimGeography' AS source_table, 655 AS source_count
  UNION ALL SELECT 'dbo.DimOrganization' AS source_table, 14 AS source_count
  UNION ALL SELECT 'dbo.DimProduct' AS source_table, 606 AS source_count
  UNION ALL SELECT 'dbo.DimProductCategory' AS source_table, 4 AS source_count
  UNION ALL SELECT 'dbo.DimProductSubcategory' AS source_table, 37 AS source_count
  UNION ALL SELECT 'dbo.DimPromotion' AS source_table, 16 AS source_count
  UNION ALL SELECT 'dbo.DimReseller' AS source_table, 701 AS source_count
  UNION ALL SELECT 'dbo.DimSalesReason' AS source_table, 10 AS source_count
  UNION ALL SELECT 'dbo.DimSalesTerritory' AS source_table, 11 AS source_count
  UNION ALL SELECT 'dbo.DimScenario' AS source_table, 3 AS source_count
  UNION ALL SELECT 'dbo.FactAdditionalInternationalProductDescription' AS source_table, 15168 AS source_count
  UNION ALL SELECT 'dbo.FactCallCenter' AS source_table, 120 AS source_count
  UNION ALL SELECT 'dbo.FactCurrencyRate' AS source_table, 14264 AS source_count
  UNION ALL SELECT 'dbo.FactFinance' AS source_table, 39409 AS source_count
  UNION ALL SELECT 'dbo.FactInternetSales' AS source_table, 60398 AS source_count
  UNION ALL SELECT 'dbo.FactInternetSalesReason' AS source_table, 64515 AS source_count
  UNION ALL SELECT 'dbo.FactProductInventory' AS source_table, 776286 AS source_count
  UNION ALL SELECT 'dbo.FactResellerSales' AS source_table, 60855 AS source_count
  UNION ALL SELECT 'dbo.FactSalesQuota' AS source_table, 163 AS source_count
  UNION ALL SELECT 'dbo.FactSurveyResponse' AS source_table, 2727 AS source_count
  UNION ALL SELECT 'dbo.NewFactCurrencyRate' AS source_table, 50 AS source_count
  UNION ALL SELECT 'dbo.ProspectiveBuyer' AS source_table, 2059 AS source_count
  UNION ALL SELECT 'dbo.sysdiagrams' AS source_table, 9 AS source_count
),
staging_counts AS (
  SELECT 'dbo.AdventureWorksDWBuildVersion' AS source_table, 'adventure_works_dw_build_version_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.adventure_works_dw_build_version_stg
  UNION ALL SELECT 'dbo.DatabaseLog' AS source_table, 'database_log_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.database_log_stg
  UNION ALL SELECT 'dbo.DimAccount' AS source_table, 'dim_account_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_account_stg
  UNION ALL SELECT 'dbo.DimCurrency' AS source_table, 'dim_currency_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_currency_stg
  UNION ALL SELECT 'dbo.DimCustomer' AS source_table, 'dim_customer_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_customer_stg
  UNION ALL SELECT 'dbo.DimDate' AS source_table, 'dim_date_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_date_stg
  UNION ALL SELECT 'dbo.DimDepartmentGroup' AS source_table, 'dim_department_group_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_department_group_stg
  UNION ALL SELECT 'dbo.DimEmployee' AS source_table, 'dim_employee_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_employee_stg
  UNION ALL SELECT 'dbo.DimGeography' AS source_table, 'dim_geography_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_geography_stg
  UNION ALL SELECT 'dbo.DimOrganization' AS source_table, 'dim_organization_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_organization_stg
  UNION ALL SELECT 'dbo.DimProduct' AS source_table, 'dim_product_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_product_stg
  UNION ALL SELECT 'dbo.DimProductCategory' AS source_table, 'dim_product_category_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_product_category_stg
  UNION ALL SELECT 'dbo.DimProductSubcategory' AS source_table, 'dim_product_subcategory_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_product_subcategory_stg
  UNION ALL SELECT 'dbo.DimPromotion' AS source_table, 'dim_promotion_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_promotion_stg
  UNION ALL SELECT 'dbo.DimReseller' AS source_table, 'dim_reseller_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_reseller_stg
  UNION ALL SELECT 'dbo.DimSalesReason' AS source_table, 'dim_sales_reason_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_sales_reason_stg
  UNION ALL SELECT 'dbo.DimSalesTerritory' AS source_table, 'dim_sales_territory_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_sales_territory_stg
  UNION ALL SELECT 'dbo.DimScenario' AS source_table, 'dim_scenario_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_scenario_stg
  UNION ALL SELECT 'dbo.FactAdditionalInternationalProductDescription' AS source_table, 'fact_additional_international_product_description_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.fact_additional_international_product_description_stg
  UNION ALL SELECT 'dbo.FactCallCenter' AS source_table, 'fact_call_center_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.fact_call_center_stg
  UNION ALL SELECT 'dbo.FactCurrencyRate' AS source_table, 'fact_currency_rate_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.fact_currency_rate_stg
  UNION ALL SELECT 'dbo.FactFinance' AS source_table, 'fact_finance_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.fact_finance_stg
  UNION ALL SELECT 'dbo.FactInternetSales' AS source_table, 'fact_internet_sales_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.fact_internet_sales_stg
  UNION ALL SELECT 'dbo.FactInternetSalesReason' AS source_table, 'fact_internet_sales_reason_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.fact_internet_sales_reason_stg
  UNION ALL SELECT 'dbo.FactProductInventory' AS source_table, 'fact_product_inventory_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.fact_product_inventory_stg
  UNION ALL SELECT 'dbo.FactResellerSales' AS source_table, 'fact_reseller_sales_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.fact_reseller_sales_stg
  UNION ALL SELECT 'dbo.FactSalesQuota' AS source_table, 'fact_sales_quota_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.fact_sales_quota_stg
  UNION ALL SELECT 'dbo.FactSurveyResponse' AS source_table, 'fact_survey_response_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.fact_survey_response_stg
  UNION ALL SELECT 'dbo.NewFactCurrencyRate' AS source_table, 'new_fact_currency_rate_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.new_fact_currency_rate_stg
  UNION ALL SELECT 'dbo.ProspectiveBuyer' AS source_table, 'prospective_buyer_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.prospective_buyer_stg
  UNION ALL SELECT 'dbo.sysdiagrams' AS source_table, 'sysdiagrams_stg' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.STAGING.sysdiagrams_stg
),
dw_counts AS (
  SELECT 'dbo.DimAccount' AS source_table, 'dim_account' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_account
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimCurrency' AS source_table, 'dim_currency' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_currency
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimCustomer' AS source_table, 'dim_customer' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_customer
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimDate' AS source_table, 'dim_date' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_date
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimDepartmentGroup' AS source_table, 'dim_department_group' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_department_group
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimEmployee' AS source_table, 'dim_employee' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_employee
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimGeography' AS source_table, 'dim_geography' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_geography
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimOrganization' AS source_table, 'dim_organization' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_organization
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimProduct' AS source_table, 'dim_product' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_product
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimProductCategory' AS source_table, 'dim_product_category' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_product_category
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimProductSubcategory' AS source_table, 'dim_product_subcategory' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_product_subcategory
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimPromotion' AS source_table, 'dim_promotion' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_promotion
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimReseller' AS source_table, 'dim_reseller' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_reseller
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimSalesReason' AS source_table, 'dim_sales_reason' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_sales_reason
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimSalesTerritory' AS source_table, 'dim_sales_territory' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_sales_territory
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimScenario' AS source_table, 'dim_scenario' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_scenario
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.FactAdditionalInternationalProductDescription' AS source_table, 'fact_additional_international_product_description' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.fact_additional_international_product_description
  UNION ALL SELECT 'dbo.FactCallCenter' AS source_table, 'fact_call_center' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.fact_call_center
  UNION ALL SELECT 'dbo.FactCurrencyRate' AS source_table, 'fact_currency_rate' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.fact_currency_rate
  UNION ALL SELECT 'dbo.FactFinance' AS source_table, 'fact_finance' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.fact_finance
  UNION ALL SELECT 'dbo.FactInternetSales' AS source_table, 'fact_internet_sales' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.fact_internet_sales
  UNION ALL SELECT 'dbo.FactInternetSalesReason' AS source_table, 'fact_internet_sales_reason' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.fact_internet_sales_reason
  UNION ALL SELECT 'dbo.FactProductInventory' AS source_table, 'fact_product_inventory' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.fact_product_inventory
  UNION ALL SELECT 'dbo.FactResellerSales' AS source_table, 'fact_reseller_sales' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.fact_reseller_sales
  UNION ALL SELECT 'dbo.FactSalesQuota' AS source_table, 'fact_sales_quota' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.fact_sales_quota
  UNION ALL SELECT 'dbo.FactSurveyResponse' AS source_table, 'fact_survey_response' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.fact_survey_response
  UNION ALL SELECT 'dbo.NewFactCurrencyRate' AS source_table, 'fact_currency_rate_incremental' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.fact_currency_rate_incremental
  UNION ALL SELECT 'dbo.ProspectiveBuyer' AS source_table, 'dim_prospective_buyer' AS target_table, COUNT(*) AS target_count
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_prospective_buyer
  WHERE _is_current = TRUE
),
staging_results AS (
  SELECT 'STAGING_PARITY' AS validation_scope,
         s.source_table,
         t.target_table,
         s.source_count,
         t.target_count,
         (t.target_count - s.source_count) AS difference,
         IFF(t.target_count = s.source_count, 'PASS', 'FAIL') AS status
  FROM source_counts s
  JOIN staging_counts t ON t.source_table = s.source_table
),
dw_results AS (
  SELECT IFF(m.is_dimension, 'DW_CURRENT_PARITY', 'DW_PARITY') AS validation_scope,
         s.source_table,
         t.target_table,
         s.source_count,
         t.target_count,
         (t.target_count - s.source_count) AS difference,
         IFF(t.target_count = s.source_count, 'PASS', 'FAIL') AS status
  FROM source_counts s
  JOIN dw_counts t ON t.source_table = s.source_table
  JOIN (
    SELECT 'dbo.DimAccount' AS source_table, TRUE AS is_dimension
    UNION ALL SELECT 'dbo.DimCurrency' AS source_table, TRUE AS is_dimension
    UNION ALL SELECT 'dbo.DimCustomer' AS source_table, TRUE AS is_dimension
    UNION ALL SELECT 'dbo.DimDate' AS source_table, TRUE AS is_dimension
    UNION ALL SELECT 'dbo.DimDepartmentGroup' AS source_table, TRUE AS is_dimension
    UNION ALL SELECT 'dbo.DimEmployee' AS source_table, TRUE AS is_dimension
    UNION ALL SELECT 'dbo.DimGeography' AS source_table, TRUE AS is_dimension
    UNION ALL SELECT 'dbo.DimOrganization' AS source_table, TRUE AS is_dimension
    UNION ALL SELECT 'dbo.DimProduct' AS source_table, TRUE AS is_dimension
    UNION ALL SELECT 'dbo.DimProductCategory' AS source_table, TRUE AS is_dimension
    UNION ALL SELECT 'dbo.DimProductSubcategory' AS source_table, TRUE AS is_dimension
    UNION ALL SELECT 'dbo.DimPromotion' AS source_table, TRUE AS is_dimension
    UNION ALL SELECT 'dbo.DimReseller' AS source_table, TRUE AS is_dimension
    UNION ALL SELECT 'dbo.DimSalesReason' AS source_table, TRUE AS is_dimension
    UNION ALL SELECT 'dbo.DimSalesTerritory' AS source_table, TRUE AS is_dimension
    UNION ALL SELECT 'dbo.DimScenario' AS source_table, TRUE AS is_dimension
    UNION ALL SELECT 'dbo.FactAdditionalInternationalProductDescription' AS source_table, FALSE AS is_dimension
    UNION ALL SELECT 'dbo.FactCallCenter' AS source_table, FALSE AS is_dimension
    UNION ALL SELECT 'dbo.FactCurrencyRate' AS source_table, FALSE AS is_dimension
    UNION ALL SELECT 'dbo.FactFinance' AS source_table, FALSE AS is_dimension
    UNION ALL SELECT 'dbo.FactInternetSales' AS source_table, FALSE AS is_dimension
    UNION ALL SELECT 'dbo.FactInternetSalesReason' AS source_table, FALSE AS is_dimension
    UNION ALL SELECT 'dbo.FactProductInventory' AS source_table, FALSE AS is_dimension
    UNION ALL SELECT 'dbo.FactResellerSales' AS source_table, FALSE AS is_dimension
    UNION ALL SELECT 'dbo.FactSalesQuota' AS source_table, FALSE AS is_dimension
    UNION ALL SELECT 'dbo.FactSurveyResponse' AS source_table, FALSE AS is_dimension
    UNION ALL SELECT 'dbo.NewFactCurrencyRate' AS source_table, FALSE AS is_dimension
    UNION ALL SELECT 'dbo.ProspectiveBuyer' AS source_table, TRUE AS is_dimension
  ) m ON m.source_table = s.source_table
)
SELECT * FROM staging_results
UNION ALL
SELECT * FROM dw_results;

SELECT validation_scope, source_table, target_table, source_count, target_count, difference, status
FROM validation_row_count_results
ORDER BY validation_scope, source_table, target_table;

SELECT validation_scope,
       IFF(COUNT_IF(status = 'FAIL') = 0, 'PASS', 'FAIL') AS scope_status,
       COUNT_IF(status = 'FAIL') AS failed_tables,
       COUNT(*) AS checked_tables
FROM validation_row_count_results
GROUP BY validation_scope
ORDER BY validation_scope;
