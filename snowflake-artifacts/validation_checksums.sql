-- validation_checksums.sql
-- Compares source key-column checksums to Snowflake STAGING and DW checksums.

USE DATABASE ADVENTUREWORKS_MIGRATED;

CREATE OR REPLACE TEMP TABLE validation_checksum_results AS
WITH source_checksums AS (
  SELECT 'dbo.AdventureWorksDWBuildVersion' AS source_table, 'DBVersion' AS key_columns, '15130868455584384691' AS source_checksum
  UNION ALL SELECT 'dbo.DatabaseLog' AS source_table, 'DatabaseLogID' AS key_columns, '14625139125088316693' AS source_checksum
  UNION ALL SELECT 'dbo.DimAccount' AS source_table, 'AccountKey' AS key_columns, '2137465620343828945' AS source_checksum
  UNION ALL SELECT 'dbo.DimCurrency' AS source_table, 'CurrencyKey' AS key_columns, '18333034755920252889' AS source_checksum
  UNION ALL SELECT 'dbo.DimCustomer' AS source_table, 'CustomerKey' AS key_columns, '7100330461688071132' AS source_checksum
  UNION ALL SELECT 'dbo.DimDate' AS source_table, 'DateKey' AS key_columns, '12111192836113270909' AS source_checksum
  UNION ALL SELECT 'dbo.DimDepartmentGroup' AS source_table, 'DepartmentGroupKey' AS key_columns, '12437988593863386734' AS source_checksum
  UNION ALL SELECT 'dbo.DimEmployee' AS source_table, 'EmployeeKey' AS key_columns, '17134194261253827694' AS source_checksum
  UNION ALL SELECT 'dbo.DimGeography' AS source_table, 'GeographyKey' AS key_columns, '15894152510059666754' AS source_checksum
  UNION ALL SELECT 'dbo.DimOrganization' AS source_table, 'OrganizationKey' AS key_columns, '2817283297105040822' AS source_checksum
  UNION ALL SELECT 'dbo.DimProduct' AS source_table, 'ProductKey' AS key_columns, '11006649797649818277' AS source_checksum
  UNION ALL SELECT 'dbo.DimProductCategory' AS source_table, 'ProductCategoryKey' AS key_columns, '2464722156703325440' AS source_checksum
  UNION ALL SELECT 'dbo.DimProductSubcategory' AS source_table, 'ProductSubcategoryKey' AS key_columns, '2265698762072386517' AS source_checksum
  UNION ALL SELECT 'dbo.DimPromotion' AS source_table, 'PromotionKey' AS key_columns, '9969197623873572510' AS source_checksum
  UNION ALL SELECT 'dbo.DimReseller' AS source_table, 'ResellerKey' AS key_columns, '6392975313467063810' AS source_checksum
  UNION ALL SELECT 'dbo.DimSalesReason' AS source_table, 'SalesReasonKey' AS key_columns, '10388509692212073493' AS source_checksum
  UNION ALL SELECT 'dbo.DimSalesTerritory' AS source_table, 'SalesTerritoryKey' AS key_columns, '17671601338737982197' AS source_checksum
  UNION ALL SELECT 'dbo.DimScenario' AS source_table, 'ScenarioKey' AS key_columns, '8769772107713361379' AS source_checksum
  UNION ALL SELECT 'dbo.FactAdditionalInternationalProductDescription' AS source_table, 'ProductKey,CultureName' AS key_columns, '16461074059774242885' AS source_checksum
  UNION ALL SELECT 'dbo.FactCallCenter' AS source_table, 'FactCallCenterID' AS key_columns, '11150490344538646158' AS source_checksum
  UNION ALL SELECT 'dbo.FactCurrencyRate' AS source_table, 'CurrencyKey,DateKey' AS key_columns, '833276882417436233' AS source_checksum
  UNION ALL SELECT 'dbo.FactFinance' AS source_table, 'FinanceKey' AS key_columns, '12771533961287541228' AS source_checksum
  UNION ALL SELECT 'dbo.FactInternetSales' AS source_table, 'SalesOrderNumber,SalesOrderLineNumber' AS key_columns, '11985977886526112248' AS source_checksum
  UNION ALL SELECT 'dbo.FactInternetSalesReason' AS source_table, 'SalesOrderNumber,SalesOrderLineNumber,SalesReasonKey' AS key_columns, '14851711497136723404' AS source_checksum
  UNION ALL SELECT 'dbo.FactProductInventory' AS source_table, 'ProductKey,DateKey' AS key_columns, '17821564523411364822' AS source_checksum
  UNION ALL SELECT 'dbo.FactResellerSales' AS source_table, 'SalesOrderNumber,SalesOrderLineNumber' AS key_columns, '3902369256371288272' AS source_checksum
  UNION ALL SELECT 'dbo.FactSalesQuota' AS source_table, 'SalesQuotaKey' AS key_columns, '9290006239127381231' AS source_checksum
  UNION ALL SELECT 'dbo.FactSurveyResponse' AS source_table, 'SurveyResponseKey' AS key_columns, '12160041614454391942' AS source_checksum
  UNION ALL SELECT 'dbo.NewFactCurrencyRate' AS source_table, 'CurrencyKey,DateKey' AS key_columns, '2386386360877452238' AS source_checksum
  UNION ALL SELECT 'dbo.ProspectiveBuyer' AS source_table, 'ProspectiveBuyerKey' AS key_columns, '9191594562154385690' AS source_checksum
  UNION ALL SELECT 'dbo.sysdiagrams' AS source_table, 'diagram_id' AS key_columns, '78393145109691803' AS source_checksum
),
staging_checksums AS (
  SELECT 'dbo.AdventureWorksDWBuildVersion' AS source_table, 'adventure_works_dw_build_version_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("DBVERSION"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.adventure_works_dw_build_version_stg
  UNION ALL SELECT 'dbo.DatabaseLog' AS source_table, 'database_log_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("DATABASELOGID"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.database_log_stg
  UNION ALL SELECT 'dbo.DimAccount' AS source_table, 'dim_account_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("ACCOUNTKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_account_stg
  UNION ALL SELECT 'dbo.DimCurrency' AS source_table, 'dim_currency_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("CURRENCYKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_currency_stg
  UNION ALL SELECT 'dbo.DimCustomer' AS source_table, 'dim_customer_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("CUSTOMERKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_customer_stg
  UNION ALL SELECT 'dbo.DimDate' AS source_table, 'dim_date_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("DATEKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_date_stg
  UNION ALL SELECT 'dbo.DimDepartmentGroup' AS source_table, 'dim_department_group_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("DEPARTMENTGROUPKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_department_group_stg
  UNION ALL SELECT 'dbo.DimEmployee' AS source_table, 'dim_employee_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("EMPLOYEEKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_employee_stg
  UNION ALL SELECT 'dbo.DimGeography' AS source_table, 'dim_geography_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("GEOGRAPHYKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_geography_stg
  UNION ALL SELECT 'dbo.DimOrganization' AS source_table, 'dim_organization_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("ORGANIZATIONKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_organization_stg
  UNION ALL SELECT 'dbo.DimProduct' AS source_table, 'dim_product_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("PRODUCTKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_product_stg
  UNION ALL SELECT 'dbo.DimProductCategory' AS source_table, 'dim_product_category_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("PRODUCTCATEGORYKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_product_category_stg
  UNION ALL SELECT 'dbo.DimProductSubcategory' AS source_table, 'dim_product_subcategory_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("PRODUCTSUBCATEGORYKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_product_subcategory_stg
  UNION ALL SELECT 'dbo.DimPromotion' AS source_table, 'dim_promotion_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("PROMOTIONKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_promotion_stg
  UNION ALL SELECT 'dbo.DimReseller' AS source_table, 'dim_reseller_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("RESELLERKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_reseller_stg
  UNION ALL SELECT 'dbo.DimSalesReason' AS source_table, 'dim_sales_reason_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("SALESREASONKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_sales_reason_stg
  UNION ALL SELECT 'dbo.DimSalesTerritory' AS source_table, 'dim_sales_territory_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("SALESTERRITORYKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_sales_territory_stg
  UNION ALL SELECT 'dbo.DimScenario' AS source_table, 'dim_scenario_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("SCENARIOKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.dim_scenario_stg
  UNION ALL SELECT 'dbo.FactAdditionalInternationalProductDescription' AS source_table, 'fact_additional_international_product_description_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("PRODUCTKEY"), '__NULL__'), COALESCE(TO_VARCHAR("CULTURENAME"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.fact_additional_international_product_description_stg
  UNION ALL SELECT 'dbo.FactCallCenter' AS source_table, 'fact_call_center_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("FACTCALLCENTERID"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.fact_call_center_stg
  UNION ALL SELECT 'dbo.FactCurrencyRate' AS source_table, 'fact_currency_rate_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("CURRENCYKEY"), '__NULL__'), COALESCE(TO_VARCHAR("DATEKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.fact_currency_rate_stg
  UNION ALL SELECT 'dbo.FactFinance' AS source_table, 'fact_finance_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("FINANCEKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.fact_finance_stg
  UNION ALL SELECT 'dbo.FactInternetSales' AS source_table, 'fact_internet_sales_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("SALESORDERNUMBER"), '__NULL__'), COALESCE(TO_VARCHAR("SALESORDERLINENUMBER"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.fact_internet_sales_stg
  UNION ALL SELECT 'dbo.FactInternetSalesReason' AS source_table, 'fact_internet_sales_reason_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("SALESORDERNUMBER"), '__NULL__'), COALESCE(TO_VARCHAR("SALESORDERLINENUMBER"), '__NULL__'), COALESCE(TO_VARCHAR("SALESREASONKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.fact_internet_sales_reason_stg
  UNION ALL SELECT 'dbo.FactProductInventory' AS source_table, 'fact_product_inventory_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("PRODUCTKEY"), '__NULL__'), COALESCE(TO_VARCHAR("DATEKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.fact_product_inventory_stg
  UNION ALL SELECT 'dbo.FactResellerSales' AS source_table, 'fact_reseller_sales_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("SALESORDERNUMBER"), '__NULL__'), COALESCE(TO_VARCHAR("SALESORDERLINENUMBER"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.fact_reseller_sales_stg
  UNION ALL SELECT 'dbo.FactSalesQuota' AS source_table, 'fact_sales_quota_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("SALESQUOTAKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.fact_sales_quota_stg
  UNION ALL SELECT 'dbo.FactSurveyResponse' AS source_table, 'fact_survey_response_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("SURVEYRESPONSEKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.fact_survey_response_stg
  UNION ALL SELECT 'dbo.NewFactCurrencyRate' AS source_table, 'new_fact_currency_rate_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("CURRENCYKEY"), '__NULL__'), COALESCE(TO_VARCHAR("DATEKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.new_fact_currency_rate_stg
  UNION ALL SELECT 'dbo.ProspectiveBuyer' AS source_table, 'prospective_buyer_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("PROSPECTIVEBUYERKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.prospective_buyer_stg
  UNION ALL SELECT 'dbo.sysdiagrams' AS source_table, 'sysdiagrams_stg' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("DIAGRAM_ID"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.STAGING.sysdiagrams_stg
),
dw_checksums AS (
  SELECT 'dbo.DimAccount' AS source_table, 'dim_account' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("ACCOUNTKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_account
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimCurrency' AS source_table, 'dim_currency' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("CURRENCYKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_currency
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimCustomer' AS source_table, 'dim_customer' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("CUSTOMERKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_customer
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimDate' AS source_table, 'dim_date' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("DATEKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_date
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimDepartmentGroup' AS source_table, 'dim_department_group' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("DEPARTMENTGROUPKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_department_group
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimEmployee' AS source_table, 'dim_employee' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("EMPLOYEEKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_employee
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimGeography' AS source_table, 'dim_geography' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("GEOGRAPHYKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_geography
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimOrganization' AS source_table, 'dim_organization' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("ORGANIZATIONKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_organization
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimProduct' AS source_table, 'dim_product' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("PRODUCTKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_product
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimProductCategory' AS source_table, 'dim_product_category' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("PRODUCTCATEGORYKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_product_category
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimProductSubcategory' AS source_table, 'dim_product_subcategory' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("PRODUCTSUBCATEGORYKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_product_subcategory
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimPromotion' AS source_table, 'dim_promotion' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("PROMOTIONKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_promotion
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimReseller' AS source_table, 'dim_reseller' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("RESELLERKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_reseller
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimSalesReason' AS source_table, 'dim_sales_reason' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("SALESREASONKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_sales_reason
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimSalesTerritory' AS source_table, 'dim_sales_territory' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("SALESTERRITORYKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_sales_territory
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.DimScenario' AS source_table, 'dim_scenario' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("SCENARIOKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_scenario
  WHERE _is_current = TRUE
  UNION ALL SELECT 'dbo.FactAdditionalInternationalProductDescription' AS source_table, 'fact_additional_international_product_description' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("PRODUCTKEY"), '__NULL__'), COALESCE(TO_VARCHAR("CULTURENAME"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.fact_additional_international_product_description
  UNION ALL SELECT 'dbo.FactCallCenter' AS source_table, 'fact_call_center' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("FACTCALLCENTERID"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.fact_call_center
  UNION ALL SELECT 'dbo.FactCurrencyRate' AS source_table, 'fact_currency_rate' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("CURRENCYKEY"), '__NULL__'), COALESCE(TO_VARCHAR("DATEKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.fact_currency_rate
  UNION ALL SELECT 'dbo.FactFinance' AS source_table, 'fact_finance' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("FINANCEKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.fact_finance
  UNION ALL SELECT 'dbo.FactInternetSales' AS source_table, 'fact_internet_sales' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("SALESORDERNUMBER"), '__NULL__'), COALESCE(TO_VARCHAR("SALESORDERLINENUMBER"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.fact_internet_sales
  UNION ALL SELECT 'dbo.FactInternetSalesReason' AS source_table, 'fact_internet_sales_reason' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("SALESORDERNUMBER"), '__NULL__'), COALESCE(TO_VARCHAR("SALESORDERLINENUMBER"), '__NULL__'), COALESCE(TO_VARCHAR("SALESREASONKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.fact_internet_sales_reason
  UNION ALL SELECT 'dbo.FactProductInventory' AS source_table, 'fact_product_inventory' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("PRODUCTKEY"), '__NULL__'), COALESCE(TO_VARCHAR("DATEKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.fact_product_inventory
  UNION ALL SELECT 'dbo.FactResellerSales' AS source_table, 'fact_reseller_sales' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("SALESORDERNUMBER"), '__NULL__'), COALESCE(TO_VARCHAR("SALESORDERLINENUMBER"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.fact_reseller_sales
  UNION ALL SELECT 'dbo.FactSalesQuota' AS source_table, 'fact_sales_quota' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("SALESQUOTAKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.fact_sales_quota
  UNION ALL SELECT 'dbo.FactSurveyResponse' AS source_table, 'fact_survey_response' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("SURVEYRESPONSEKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.fact_survey_response
  UNION ALL SELECT 'dbo.NewFactCurrencyRate' AS source_table, 'fact_currency_rate_incremental' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("CURRENCYKEY"), '__NULL__'), COALESCE(TO_VARCHAR("DATEKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.fact_currency_rate_incremental
  UNION ALL SELECT 'dbo.ProspectiveBuyer' AS source_table, 'dim_prospective_buyer' AS target_table, TO_VARCHAR(MOD(COALESCE(SUM(TO_NUMBER(SUBSTR(MD5_HEX(CONCAT_WS('||', COALESCE(TO_VARCHAR("PROSPECTIVEBUYERKEY"), '__NULL__'))), 1, 16), 'XXXXXXXXXXXXXXXX')), 0), 18446744073709551616)) AS target_checksum
  FROM ADVENTUREWORKS_MIGRATED.DW.dim_prospective_buyer
  WHERE _is_current = TRUE
),
staging_results AS (
  SELECT 'STAGING_CHECKSUM' AS validation_scope,
         s.source_table,
         t.target_table,
         s.key_columns,
         s.source_checksum,
         t.target_checksum,
         IFF(s.source_checksum = t.target_checksum, 'PASS', 'FAIL') AS status
  FROM source_checksums s
  JOIN staging_checksums t ON t.source_table = s.source_table
),
dw_results AS (
  SELECT IFF(m.is_dimension, 'DW_CURRENT_CHECKSUM', 'DW_CHECKSUM') AS validation_scope,
         s.source_table,
         t.target_table,
         s.key_columns,
         s.source_checksum,
         t.target_checksum,
         IFF(s.source_checksum = t.target_checksum, 'PASS', 'FAIL') AS status
  FROM source_checksums s
  JOIN dw_checksums t ON t.source_table = s.source_table
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

SELECT validation_scope, source_table, target_table, key_columns, source_checksum, target_checksum, status
FROM validation_checksum_results
ORDER BY validation_scope, source_table, target_table;

SELECT validation_scope,
       IFF(COUNT_IF(status = 'FAIL') = 0, 'PASS', 'FAIL') AS scope_status,
       COUNT_IF(status = 'FAIL') AS failed_tables,
       COUNT(*) AS checked_tables
FROM validation_checksum_results
GROUP BY validation_scope
ORDER BY validation_scope;
