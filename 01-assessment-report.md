# 01-assessment-report

## Scope and Sources Parsed

- Parsed `source/etl-repo/` and `source/dashboard-repo/` recursively for artifact discovery.
- Queried live source database `AdventureWorksDW2022` (SQL Server container) to enumerate all base tables, views, functions, and stored procedures.
- Applied mission heuristic for complexity scoring:
  - **Simple**: direct loads/projections, simple types, no SCD behavior
  - **Medium**: simple lookups/joins, moderate dependencies, minor type/shape transforms
  - **Complex**: SCD Type 2 behavior, multi-source joins, heavy fact integration, or custom transformation logic

## Artifact Type Discovery Summary

| Artifact Type | Location | Count | Notes |
| --- | --- | ---: | --- |
| T-SQL scripts (`.sql`) | source/etl-repo/Scripts | 5 | Schema prep + DW definition + constraints + extraction query |
| SSIS packages (`.dtsx`) | source/etl-repo | 0 | No `.dtsx` files present in cloned repo; flow inferred from README/images |
| Images / diagrams | source/etl-repo/Images | 3 | Control flow/data flow/transformation visuals |
| Power BI dashboard (`.pbix`) | source/dashboard-repo | 1 | Primary dashboard artifact |
| Dashboard SQL scripts (`.sql`) | source/dashboard-repo/Scripts | 4 | Cleansing/projection SQL used by dashboard model |
| Dashboard data tables (`.csv`) | source/dashboard-repo/Tables | 4 | DIM/FACT extracts |
| Budget workbook (`.xlsx`) | source/dashboard-repo/Tables | 1 | Budget comparison input |
| Business request (`.docx`) | source/dashboard-repo | 1 | Functional requirements context |
| Dashboard screenshots | source/dashboard-repo/Screenshots | 4 | Page-level visuals and data model image |

## Structured Object Inventory (Required Migration Objects)

Total inventoried required objects: **48**

| Name | Type | Source | Complexity | Dependencies | Metadata |
| --- | --- | --- | --- | --- | --- |
| dbo.AdventureWorksDWBuildVersion | Table | AdventureWorksDW2022 | Simple | none | row_count=1 |
| dbo.DatabaseLog | Table | AdventureWorksDW2022 | Simple | none | row_count=96 |
| dbo.DimAccount | Table | AdventureWorksDW2022 | Simple | dbo.DimAccount | row_count=99 |
| dbo.DimCurrency | Table | AdventureWorksDW2022 | Simple | none | row_count=105 |
| dbo.DimCustomer | Table | AdventureWorksDW2022 | Complex | dbo.DimGeography | row_count=18484 |
| dbo.DimDate | Table | AdventureWorksDW2022 | Simple | none | row_count=3652 |
| dbo.DimDepartmentGroup | Table | AdventureWorksDW2022 | Simple | dbo.DimDepartmentGroup | row_count=7 |
| dbo.DimEmployee | Table | AdventureWorksDW2022 | Medium | dbo.DimEmployee, dbo.DimSalesTerritory | row_count=296 |
| dbo.DimGeography | Table | AdventureWorksDW2022 | Simple | dbo.DimSalesTerritory | row_count=655 |
| dbo.DimOrganization | Table | AdventureWorksDW2022 | Medium | dbo.DimCurrency, dbo.DimOrganization | row_count=14 |
| dbo.DimProduct | Table | AdventureWorksDW2022 | Complex | dbo.DimProductSubcategory | row_count=606 |
| dbo.DimProductCategory | Table | AdventureWorksDW2022 | Simple | none | row_count=4 |
| dbo.DimProductSubcategory | Table | AdventureWorksDW2022 | Simple | dbo.DimProductCategory | row_count=37 |
| dbo.DimPromotion | Table | AdventureWorksDW2022 | Simple | none | row_count=16 |
| dbo.DimReseller | Table | AdventureWorksDW2022 | Simple | dbo.DimGeography | row_count=701 |
| dbo.DimSalesReason | Table | AdventureWorksDW2022 | Simple | none | row_count=10 |
| dbo.DimSalesTerritory | Table | AdventureWorksDW2022 | Simple | none | row_count=11 |
| dbo.DimScenario | Table | AdventureWorksDW2022 | Simple | none | row_count=3 |
| dbo.FactAdditionalInternationalProductDescription | Table | AdventureWorksDW2022 | Medium | none | row_count=15168 |
| dbo.FactCallCenter | Table | AdventureWorksDW2022 | Simple | dbo.DimDate | row_count=120 |
| dbo.FactCurrencyRate | Table | AdventureWorksDW2022 | Medium | dbo.DimCurrency, dbo.DimDate | row_count=14264 |
| dbo.FactFinance | Table | AdventureWorksDW2022 | Complex | dbo.DimAccount, dbo.DimDate, dbo.DimDepartmentGroup, dbo.DimOrganization, dbo.DimScenario | row_count=39409 |
| dbo.FactInternetSales | Table | AdventureWorksDW2022 | Complex | dbo.DimCurrency, dbo.DimCustomer, dbo.DimDate, dbo.DimProduct, dbo.DimPromotion, dbo.DimSalesTerritory | row_count=60398 |
| dbo.FactInternetSalesReason | Table | AdventureWorksDW2022 | Medium | dbo.DimSalesReason, dbo.FactInternetSales | row_count=64515 |
| dbo.FactProductInventory | Table | AdventureWorksDW2022 | Complex | dbo.DimDate, dbo.DimProduct | row_count=776286 |
| dbo.FactResellerSales | Table | AdventureWorksDW2022 | Complex | dbo.DimCurrency, dbo.DimDate, dbo.DimEmployee, dbo.DimProduct, dbo.DimPromotion, dbo.DimReseller, dbo.DimSalesTerritory | row_count=60855 |
| dbo.FactSalesQuota | Table | AdventureWorksDW2022 | Medium | dbo.DimDate, dbo.DimEmployee | row_count=163 |
| dbo.FactSurveyResponse | Table | AdventureWorksDW2022 | Medium | dbo.DimCustomer, dbo.DimDate | row_count=2727 |
| dbo.NewFactCurrencyRate | Table | AdventureWorksDW2022 | Simple | none | row_count=50 |
| dbo.ProspectiveBuyer | Table | AdventureWorksDW2022 | Simple | none | row_count=2059 |
| dbo.sysdiagrams | Table | AdventureWorksDW2022 | Simple | none | row_count=9 |
| SSIS::Customer OLE DB Source | Transformation | source/etl-repo/README.md | Medium | AdventureWorks OLTP Person/Sales tables | Extracts customer entities for dimensional load |
| SSIS::Customer-YearlyIncome Flat File Source | Transformation | source/etl-repo/README.md | Simple | CSV flat file | Imports external yearly income data |
| SSIS::Sort (Customer-YearlyIncome) | Transformation | source/etl-repo/README.md | Simple | Customer-YearlyIncome Flat File Source | Prepares sorted stream for Merge Join |
| SSIS::Merge Join (Left Outer) | Transformation | source/etl-repo/README.md | Complex | Customer OLE DB Source, Sorted Flat File Source | Combines OLTP customer data with flat-file income data |
| SSIS::Lookup enrichment | Transformation | source/etl-repo/README.md | Medium | Staging/reference tables | Enriches rows with lookup values |
| SSIS::Derived Column | Transformation | source/etl-repo/README.md | Medium | Lookup output | Applies conditional/default value derivations |
| SSIS::Union All | Transformation | source/etl-repo/README.md | Simple | Derived Column output, lookup non-matches | Recombines transformed streams |
| SSIS::SCD Type 2 load | Transformation | source/etl-repo/README.md | Complex | Customer dimension target table | Maintains history for changing customer attributes |
| SSIS::OLE DB Destination (DimCustomer) | Transformation | source/etl-repo/README.md | Medium | Union/SCD outputs, dbo.DimCustomer | Loads transformed rows into DW dimension |
| SQL::DIM_Customer Cleansing | Transformation | source/dashboard-repo/Scripts/DIM_Customer Cleansing.sql | Medium | dbo.DimCustomer, dbo.DimGeography | Join + derived full-name and gender mapping |
| SQL::DIM_Product Cleansing | Transformation | source/dashboard-repo/Scripts/DIM_Product Cleansing.sql | Medium | dbo.DimProduct, dbo.DimProductSubcategory, dbo.DimProductCategory | Joins product hierarchy and status normalization |
| SQL::DIM_Calender Cleansing | Transformation | source/dashboard-repo/Scripts/DIM_Calender Cleansing.sql | Simple | dbo.DimDate | Date formatting/filter projection for analytics |
| SQL::FACT_InternetSales filter | Transformation | source/dashboard-repo/Scripts/FACT_InternetSales.sql | Simple | dbo.FactInternetSales | Date filter (2019+) and projection for dashboard fact set |
| source/dashboard-repo/AdventureWorks Sales Performance Dashboard.pbix | Dashboard | Power BI | Complex | DIM_*.csv, FACT_InternetSales.csv, SalesBudget.xlsx, SQL cleansing scripts | Primary dashboard artifact for migration |
| Power BI page: Sales Overview | Dashboard | source/dashboard-repo/Screenshots | Medium | Power BI data model | Derived from page screenshots in repository |
| Power BI page: Product Details | Dashboard | source/dashboard-repo/Screenshots | Medium | Power BI data model | Derived from page screenshots in repository |
| Power BI page: Customer Details | Dashboard | source/dashboard-repo/Screenshots | Medium | Power BI data model | Derived from page screenshots in repository |

## Supplemental Source Objects (Views/Functions/Procedures)

- Stored procedures discovered in source DB: **0**
- No user stored procedures were found in `AdventureWorksDW2022` metadata.

| Name | Object Type | Complexity | Dependencies |
| --- | --- | --- | --- |
| dbo.vAssocSeqLineItems | View | Medium | dbo.vDMPrep |
| dbo.vAssocSeqOrders | View | Medium | dbo.vDMPrep |
| dbo.vDMPrep | View | Medium | dbo.DimCustomer, dbo.DimDate, dbo.DimGeography, dbo.DimProduct, dbo.DimProductCategory, dbo.DimProductSubcategory, dbo.DimSalesTerritory, dbo.FactInternetSales |
| dbo.vTargetMail | View | Medium | dbo.DimCustomer, dbo.vDMPrep |
| dbo.vTimeSeries | View | Medium | dbo.udfBuildISO8601Date, dbo.vDMPrep |
| dbo.udfBuildISO8601Date | Function | Medium | dbo.udfTwoDigitZeroFill |
| dbo.udfMinimumDate | Function | Simple | none |
| dbo.udfTwoDigitZeroFill | Function | Simple | none |

## Complexity Distribution

| Complexity | Object Count | Share |
| --- | ---: | ---: |
| Simple | 23 | 47.9% |
| Medium | 16 | 33.3% |
| Complex | 9 | 18.8% |

## Recommended Target Primitives (Snowpark Notebooks)

- **Snowpark Notebook: `nb_load_staging`** for deterministic extraction-file-to-staging ingest flows.
- **Snowpark Notebook: `nb_dim_scd2`** for dimension history logic (`DimCustomer`, `DimProduct`) with merge semantics.
- **Snowpark Notebook: `nb_fact_loads`** for high-volume fact table loading and key resolution.
- **Snowpark Notebook: `nb_dashboard_marts`** to materialize dashboard-ready aggregates/views for Power BI parity.
- **Snowflake Task (suspended) + notebook orchestration** for scheduled data quality and refresh operations.

## Known Risk Areas

1. **Missing `.dtsx` package files** in the cloned ETL repo: control/data flow is documented, but package XML metadata is unavailable for direct parser extraction.
2. **SCD Type 2 complexity** in customer/product dimensions requires careful historical merge logic and validity-window integrity checks.
3. **Legacy SQL Server constructs** (XML `.value()`, T-SQL date functions, `money`, and naming drift between DW2012/DW2019/DW2022 scripts) require explicit Snowflake mapping rules.
4. **High-volume fact tables** (`FactProductInventory`, `FactInternetSales`, `FactResellerSales`) need staged, repeatable load patterns and reconciliation controls.
5. **Dashboard coupling to cleansed SQL scripts + external budget workbook** introduces semantic parity risk during repoint/rebuild.

## Recommended Migration Strategy

1. **Baseline mapping:** Freeze inventory-driven source-to-target mapping for every table and transformation before code generation.
2. **Schema-first rollout:** Generate Snowflake `STAGING`, then `DW`, then `UTILITY` objects to preserve dependency order.
3. **Notebookized ETL:** Implement all transformation classes in Snowpark notebooks (staging ingest, SCD2 dimensions, facts, data quality).
4. **Progressive validation:** After each notebook stage, run row-count and key-integrity checks against SQL Server source.
5. **Dashboard migration path:** Repoint Power BI to Snowflake-compatible marts first; optionally rebuild in Streamlit for Snowflake-native operation.

