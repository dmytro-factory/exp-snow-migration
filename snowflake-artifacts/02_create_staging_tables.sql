-- 02_create_staging_tables.sql

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.adventure_works_dw_build_version_stg (
  DBVersion VARCHAR(50),
  VersionDate TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.database_log_stg (
  DatabaseLogID NUMBER(10,0) NOT NULL,
  PostTime TIMESTAMP_NTZ NOT NULL,
  DatabaseUser VARCHAR(128) NOT NULL,
  Event VARCHAR(128) NOT NULL,
  Schema VARCHAR(128),
  Object VARCHAR(128),
  TSQL VARCHAR NOT NULL,
  XmlEvent VARIANT NOT NULL
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.dim_account_stg (
  AccountKey NUMBER(10,0) NOT NULL,
  ParentAccountKey NUMBER(10,0),
  AccountCodeAlternateKey NUMBER(10,0),
  ParentAccountCodeAlternateKey NUMBER(10,0),
  AccountDescription VARCHAR(50),
  AccountType VARCHAR(50),
  Operator VARCHAR(50),
  CustomMembers VARCHAR(300),
  ValueType VARCHAR(50),
  CustomMemberOptions VARCHAR(200)
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.dim_currency_stg (
  CurrencyKey NUMBER(10,0) NOT NULL,
  CurrencyAlternateKey NCHAR(3) NOT NULL,
  CurrencyName VARCHAR(50) NOT NULL
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.dim_customer_stg (
  CustomerKey NUMBER(10,0) NOT NULL,
  GeographyKey NUMBER(10,0),
  CustomerAlternateKey VARCHAR(15) NOT NULL,
  Title VARCHAR(8),
  FirstName VARCHAR(50),
  MiddleName VARCHAR(50),
  LastName VARCHAR(50),
  NameStyle BOOLEAN,
  BirthDate DATE,
  MaritalStatus NCHAR(1),
  Suffix VARCHAR(10),
  Gender VARCHAR(1),
  EmailAddress VARCHAR(50),
  YearlyIncome NUMBER(19,4),
  TotalChildren NUMBER(3,0),
  NumberChildrenAtHome NUMBER(3,0),
  EnglishEducation VARCHAR(40),
  SpanishEducation VARCHAR(40),
  FrenchEducation VARCHAR(40),
  EnglishOccupation VARCHAR(100),
  SpanishOccupation VARCHAR(100),
  FrenchOccupation VARCHAR(100),
  HouseOwnerFlag NCHAR(1),
  NumberCarsOwned NUMBER(3,0),
  AddressLine1 VARCHAR(120),
  AddressLine2 VARCHAR(120),
  Phone VARCHAR(20),
  DateFirstPurchase DATE,
  CommuteDistance VARCHAR(15)
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.dim_date_stg (
  DateKey NUMBER(10,0) NOT NULL,
  FullDateAlternateKey DATE NOT NULL,
  DayNumberOfWeek NUMBER(3,0) NOT NULL,
  EnglishDayNameOfWeek VARCHAR(10) NOT NULL,
  SpanishDayNameOfWeek VARCHAR(10) NOT NULL,
  FrenchDayNameOfWeek VARCHAR(10) NOT NULL,
  DayNumberOfMonth NUMBER(3,0) NOT NULL,
  DayNumberOfYear NUMBER(5,0) NOT NULL,
  WeekNumberOfYear NUMBER(3,0) NOT NULL,
  EnglishMonthName VARCHAR(10) NOT NULL,
  SpanishMonthName VARCHAR(10) NOT NULL,
  FrenchMonthName VARCHAR(10) NOT NULL,
  MonthNumberOfYear NUMBER(3,0) NOT NULL,
  CalendarQuarter NUMBER(3,0) NOT NULL,
  CalendarYear NUMBER(5,0) NOT NULL,
  CalendarSemester NUMBER(3,0) NOT NULL,
  FiscalQuarter NUMBER(3,0) NOT NULL,
  FiscalYear NUMBER(5,0) NOT NULL,
  FiscalSemester NUMBER(3,0) NOT NULL
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.dim_department_group_stg (
  DepartmentGroupKey NUMBER(10,0) NOT NULL,
  ParentDepartmentGroupKey NUMBER(10,0),
  DepartmentGroupName VARCHAR(50)
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.dim_employee_stg (
  EmployeeKey NUMBER(10,0) NOT NULL,
  ParentEmployeeKey NUMBER(10,0),
  EmployeeNationalIDAlternateKey VARCHAR(15),
  ParentEmployeeNationalIDAlternateKey VARCHAR(15),
  SalesTerritoryKey NUMBER(10,0),
  FirstName VARCHAR(50) NOT NULL,
  LastName VARCHAR(50) NOT NULL,
  MiddleName VARCHAR(50),
  NameStyle BOOLEAN NOT NULL,
  Title VARCHAR(50),
  HireDate DATE,
  BirthDate DATE,
  LoginID VARCHAR(256),
  EmailAddress VARCHAR(50),
  Phone VARCHAR(25),
  MaritalStatus NCHAR(1),
  EmergencyContactName VARCHAR(50),
  EmergencyContactPhone VARCHAR(25),
  SalariedFlag BOOLEAN,
  Gender NCHAR(1),
  PayFrequency NUMBER(3,0),
  BaseRate NUMBER(19,4),
  VacationHours NUMBER(5,0),
  SickLeaveHours NUMBER(5,0),
  CurrentFlag BOOLEAN NOT NULL,
  SalesPersonFlag BOOLEAN NOT NULL,
  DepartmentName VARCHAR(50),
  StartDate DATE,
  EndDate DATE,
  Status VARCHAR(50),
  EmployeePhoto BINARY
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.dim_geography_stg (
  GeographyKey NUMBER(10,0) NOT NULL,
  City VARCHAR(30),
  StateProvinceCode VARCHAR(3),
  StateProvinceName VARCHAR(50),
  CountryRegionCode VARCHAR(3),
  EnglishCountryRegionName VARCHAR(50),
  SpanishCountryRegionName VARCHAR(50),
  FrenchCountryRegionName VARCHAR(50),
  PostalCode VARCHAR(15),
  SalesTerritoryKey NUMBER(10,0),
  IpAddressLocator VARCHAR(15)
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.dim_organization_stg (
  OrganizationKey NUMBER(10,0) NOT NULL,
  ParentOrganizationKey NUMBER(10,0),
  PercentageOfOwnership VARCHAR(16),
  OrganizationName VARCHAR(50),
  CurrencyKey NUMBER(10,0)
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.dim_product_stg (
  ProductKey NUMBER(10,0) NOT NULL,
  ProductAlternateKey VARCHAR(25),
  ProductSubcategoryKey NUMBER(10,0),
  WeightUnitMeasureCode NCHAR(3),
  SizeUnitMeasureCode NCHAR(3),
  EnglishProductName VARCHAR(50) NOT NULL,
  SpanishProductName VARCHAR(50) NOT NULL,
  FrenchProductName VARCHAR(50) NOT NULL,
  StandardCost NUMBER(19,4),
  FinishedGoodsFlag BOOLEAN NOT NULL,
  Color VARCHAR(15) NOT NULL,
  SafetyStockLevel NUMBER(5,0),
  ReorderPoint NUMBER(5,0),
  ListPrice NUMBER(19,4),
  Size VARCHAR(50),
  SizeRange VARCHAR(50),
  Weight FLOAT,
  DaysToManufacture NUMBER(10,0),
  ProductLine NCHAR(2),
  DealerPrice NUMBER(19,4),
  Class NCHAR(2),
  Style NCHAR(2),
  ModelName VARCHAR(50),
  LargePhoto BINARY,
  EnglishDescription VARCHAR(400),
  FrenchDescription VARCHAR(400),
  ChineseDescription VARCHAR(400),
  ArabicDescription VARCHAR(400),
  HebrewDescription VARCHAR(400),
  ThaiDescription VARCHAR(400),
  GermanDescription VARCHAR(400),
  JapaneseDescription VARCHAR(400),
  TurkishDescription VARCHAR(400),
  StartDate TIMESTAMP_NTZ,
  EndDate TIMESTAMP_NTZ,
  Status VARCHAR(7)
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.dim_product_category_stg (
  ProductCategoryKey NUMBER(10,0) NOT NULL,
  ProductCategoryAlternateKey NUMBER(10,0),
  EnglishProductCategoryName VARCHAR(50) NOT NULL,
  SpanishProductCategoryName VARCHAR(50) NOT NULL,
  FrenchProductCategoryName VARCHAR(50) NOT NULL
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.dim_product_subcategory_stg (
  ProductSubcategoryKey NUMBER(10,0) NOT NULL,
  ProductSubcategoryAlternateKey NUMBER(10,0),
  EnglishProductSubcategoryName VARCHAR(50) NOT NULL,
  SpanishProductSubcategoryName VARCHAR(50) NOT NULL,
  FrenchProductSubcategoryName VARCHAR(50) NOT NULL,
  ProductCategoryKey NUMBER(10,0)
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.dim_promotion_stg (
  PromotionKey NUMBER(10,0) NOT NULL,
  PromotionAlternateKey NUMBER(10,0),
  EnglishPromotionName VARCHAR(255),
  SpanishPromotionName VARCHAR(255),
  FrenchPromotionName VARCHAR(255),
  DiscountPct FLOAT,
  EnglishPromotionType VARCHAR(50),
  SpanishPromotionType VARCHAR(50),
  FrenchPromotionType VARCHAR(50),
  EnglishPromotionCategory VARCHAR(50),
  SpanishPromotionCategory VARCHAR(50),
  FrenchPromotionCategory VARCHAR(50),
  StartDate TIMESTAMP_NTZ NOT NULL,
  EndDate TIMESTAMP_NTZ,
  MinQty NUMBER(10,0),
  MaxQty NUMBER(10,0)
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.dim_reseller_stg (
  ResellerKey NUMBER(10,0) NOT NULL,
  GeographyKey NUMBER(10,0),
  ResellerAlternateKey VARCHAR(15),
  Phone VARCHAR(25),
  BusinessType VARCHAR(20) NOT NULL,
  ResellerName VARCHAR(50) NOT NULL,
  NumberEmployees NUMBER(10,0),
  OrderFrequency CHAR(1),
  OrderMonth NUMBER(3,0),
  FirstOrderYear NUMBER(10,0),
  LastOrderYear NUMBER(10,0),
  ProductLine VARCHAR(50),
  AddressLine1 VARCHAR(60),
  AddressLine2 VARCHAR(60),
  AnnualSales NUMBER(19,4),
  BankName VARCHAR(50),
  MinPaymentType NUMBER(3,0),
  MinPaymentAmount NUMBER(19,4),
  AnnualRevenue NUMBER(19,4),
  YearOpened NUMBER(10,0)
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.dim_sales_reason_stg (
  SalesReasonKey NUMBER(10,0) NOT NULL,
  SalesReasonAlternateKey NUMBER(10,0) NOT NULL,
  SalesReasonName VARCHAR(50) NOT NULL,
  SalesReasonReasonType VARCHAR(50) NOT NULL
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.dim_sales_territory_stg (
  SalesTerritoryKey NUMBER(10,0) NOT NULL,
  SalesTerritoryAlternateKey NUMBER(10,0),
  SalesTerritoryRegion VARCHAR(50) NOT NULL,
  SalesTerritoryCountry VARCHAR(50) NOT NULL,
  SalesTerritoryGroup VARCHAR(50),
  SalesTerritoryImage BINARY
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.dim_scenario_stg (
  ScenarioKey NUMBER(10,0) NOT NULL,
  ScenarioName VARCHAR(50)
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.fact_additional_international_product_description_stg (
  ProductKey NUMBER(10,0) NOT NULL,
  CultureName VARCHAR(50) NOT NULL,
  ProductDescription VARCHAR NOT NULL
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.fact_call_center_stg (
  FactCallCenterID NUMBER(10,0) NOT NULL,
  DateKey NUMBER(10,0) NOT NULL,
  WageType VARCHAR(15) NOT NULL,
  Shift VARCHAR(20) NOT NULL,
  LevelOneOperators NUMBER(5,0) NOT NULL,
  LevelTwoOperators NUMBER(5,0) NOT NULL,
  TotalOperators NUMBER(5,0) NOT NULL,
  Calls NUMBER(10,0) NOT NULL,
  AutomaticResponses NUMBER(10,0) NOT NULL,
  Orders NUMBER(10,0) NOT NULL,
  IssuesRaised NUMBER(5,0) NOT NULL,
  AverageTimePerIssue NUMBER(5,0) NOT NULL,
  ServiceGrade FLOAT NOT NULL,
  Date TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.fact_currency_rate_stg (
  CurrencyKey NUMBER(10,0) NOT NULL,
  DateKey NUMBER(10,0) NOT NULL,
  AverageRate FLOAT NOT NULL,
  EndOfDayRate FLOAT NOT NULL,
  Date TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.fact_finance_stg (
  FinanceKey NUMBER(10,0) NOT NULL,
  DateKey NUMBER(10,0) NOT NULL,
  OrganizationKey NUMBER(10,0) NOT NULL,
  DepartmentGroupKey NUMBER(10,0) NOT NULL,
  ScenarioKey NUMBER(10,0) NOT NULL,
  AccountKey NUMBER(10,0) NOT NULL,
  Amount FLOAT NOT NULL,
  Date TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.fact_internet_sales_stg (
  ProductKey NUMBER(10,0) NOT NULL,
  OrderDateKey NUMBER(10,0) NOT NULL,
  DueDateKey NUMBER(10,0) NOT NULL,
  ShipDateKey NUMBER(10,0) NOT NULL,
  CustomerKey NUMBER(10,0) NOT NULL,
  PromotionKey NUMBER(10,0) NOT NULL,
  CurrencyKey NUMBER(10,0) NOT NULL,
  SalesTerritoryKey NUMBER(10,0) NOT NULL,
  SalesOrderNumber VARCHAR(20) NOT NULL,
  SalesOrderLineNumber NUMBER(3,0) NOT NULL,
  RevisionNumber NUMBER(3,0) NOT NULL,
  OrderQuantity NUMBER(5,0) NOT NULL,
  UnitPrice NUMBER(19,4) NOT NULL,
  ExtendedAmount NUMBER(19,4) NOT NULL,
  UnitPriceDiscountPct FLOAT NOT NULL,
  DiscountAmount FLOAT NOT NULL,
  ProductStandardCost NUMBER(19,4) NOT NULL,
  TotalProductCost NUMBER(19,4) NOT NULL,
  SalesAmount NUMBER(19,4) NOT NULL,
  TaxAmt NUMBER(19,4) NOT NULL,
  Freight NUMBER(19,4) NOT NULL,
  CarrierTrackingNumber VARCHAR(25),
  CustomerPONumber VARCHAR(25),
  OrderDate TIMESTAMP_NTZ,
  DueDate TIMESTAMP_NTZ,
  ShipDate TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.fact_internet_sales_reason_stg (
  SalesOrderNumber VARCHAR(20) NOT NULL,
  SalesOrderLineNumber NUMBER(3,0) NOT NULL,
  SalesReasonKey NUMBER(10,0) NOT NULL
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.fact_product_inventory_stg (
  ProductKey NUMBER(10,0) NOT NULL,
  DateKey NUMBER(10,0) NOT NULL,
  MovementDate DATE NOT NULL,
  UnitCost NUMBER(19,4) NOT NULL,
  UnitsIn NUMBER(10,0) NOT NULL,
  UnitsOut NUMBER(10,0) NOT NULL,
  UnitsBalance NUMBER(10,0) NOT NULL
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.fact_reseller_sales_stg (
  ProductKey NUMBER(10,0) NOT NULL,
  OrderDateKey NUMBER(10,0) NOT NULL,
  DueDateKey NUMBER(10,0) NOT NULL,
  ShipDateKey NUMBER(10,0) NOT NULL,
  ResellerKey NUMBER(10,0) NOT NULL,
  EmployeeKey NUMBER(10,0) NOT NULL,
  PromotionKey NUMBER(10,0) NOT NULL,
  CurrencyKey NUMBER(10,0) NOT NULL,
  SalesTerritoryKey NUMBER(10,0) NOT NULL,
  SalesOrderNumber VARCHAR(20) NOT NULL,
  SalesOrderLineNumber NUMBER(3,0) NOT NULL,
  RevisionNumber NUMBER(3,0),
  OrderQuantity NUMBER(5,0),
  UnitPrice NUMBER(19,4),
  ExtendedAmount NUMBER(19,4),
  UnitPriceDiscountPct FLOAT,
  DiscountAmount FLOAT,
  ProductStandardCost NUMBER(19,4),
  TotalProductCost NUMBER(19,4),
  SalesAmount NUMBER(19,4),
  TaxAmt NUMBER(19,4),
  Freight NUMBER(19,4),
  CarrierTrackingNumber VARCHAR(25),
  CustomerPONumber VARCHAR(25),
  OrderDate TIMESTAMP_NTZ,
  DueDate TIMESTAMP_NTZ,
  ShipDate TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.fact_sales_quota_stg (
  SalesQuotaKey NUMBER(10,0) NOT NULL,
  EmployeeKey NUMBER(10,0) NOT NULL,
  DateKey NUMBER(10,0) NOT NULL,
  CalendarYear NUMBER(5,0) NOT NULL,
  CalendarQuarter NUMBER(3,0) NOT NULL,
  SalesAmountQuota NUMBER(19,4) NOT NULL,
  Date TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.fact_survey_response_stg (
  SurveyResponseKey NUMBER(10,0) NOT NULL,
  DateKey NUMBER(10,0) NOT NULL,
  CustomerKey NUMBER(10,0) NOT NULL,
  ProductCategoryKey NUMBER(10,0) NOT NULL,
  EnglishProductCategoryName VARCHAR(50) NOT NULL,
  ProductSubcategoryKey NUMBER(10,0) NOT NULL,
  EnglishProductSubcategoryName VARCHAR(50) NOT NULL,
  Date TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.new_fact_currency_rate_stg (
  AverageRate FLOAT,
  CurrencyID VARCHAR(3),
  CurrencyDate DATE,
  EndOfDayRate FLOAT,
  CurrencyKey NUMBER(10,0),
  DateKey NUMBER(10,0)
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.prospective_buyer_stg (
  ProspectiveBuyerKey NUMBER(10,0) NOT NULL,
  ProspectAlternateKey VARCHAR(15),
  FirstName VARCHAR(50),
  MiddleName VARCHAR(50),
  LastName VARCHAR(50),
  BirthDate TIMESTAMP_NTZ,
  MaritalStatus NCHAR(1),
  Gender VARCHAR(1),
  EmailAddress VARCHAR(50),
  YearlyIncome NUMBER(19,4),
  TotalChildren NUMBER(3,0),
  NumberChildrenAtHome NUMBER(3,0),
  Education VARCHAR(40),
  Occupation VARCHAR(100),
  HouseOwnerFlag NCHAR(1),
  NumberCarsOwned NUMBER(3,0),
  AddressLine1 VARCHAR(120),
  AddressLine2 VARCHAR(120),
  City VARCHAR(30),
  StateProvinceCode VARCHAR(3),
  PostalCode VARCHAR(15),
  Phone VARCHAR(20),
  Salutation VARCHAR(8),
  Unknown NUMBER(10,0)
);

CREATE OR REPLACE TABLE ADVENTUREWORKS_MIGRATED.STAGING.sysdiagrams_stg (
  name VARCHAR(128) NOT NULL,
  principal_id NUMBER(10,0) NOT NULL,
  diagram_id NUMBER(10,0) NOT NULL,
  version NUMBER(10,0),
  definition BINARY
);
