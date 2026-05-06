# Power BI Repoint Guide: SQL Server → Snowflake

## 1) Scope and analyzed assets

This guide is based on:

- `source/dashboard-repo/AdventureWorks Sales Performance Dashboard.pbix`
- `source/dashboard-repo/Tables/*.csv` and `SalesBudget.xlsx`
- `source/dashboard-repo/Scripts/*.sql`

Detected report pages in the `.pbix`:

- `Sales Overview`
- `Customer Details`
- `Product Details`

Detected model references in visuals:

- Tables/fields: `DIM_Calender.*`, `DIM_Customer.*`, `DIM_Product.*`, `FACT_InternetSales.SalesAmount`
- Measures: `Key Measures.Sales`, `Key Measures.Budget Amount`, `Key Measures.Sales - Budget`

---

## 2) Prerequisites

1. Power BI Desktop (current version).
2. Access to Snowflake account `KLDJZPG-RTB48613`.
3. Warehouse/database objects already deployed:
   - Warehouse: `ADVENTUREWORKS_BI_WH`
   - Database: `ADVENTUREWORKS_MIGRATED`
   - Schema: `DW`
4. Credentials with read access (recommended: least-privilege BI role; `ACCOUNTADMIN` only for setup/troubleshooting).

---

## 3) Source-to-target table mapping

| Current model object | Source repo artifact | Snowflake target |
|---|---|---|
| `DIM_Calender` | `Tables/DIM_Calender.csv` + `Scripts/DIM_Calender Cleansing.sql` | `ADVENTUREWORKS_MIGRATED.DW.DIM_DATE` |
| `DIM_Customer` | `Tables/DIM_Customer.csv` + `Scripts/DIM_Customer Cleansing.sql` | `ADVENTUREWORKS_MIGRATED.DW.DIM_CUSTOMER` |
| `DIM_Product` | `Tables/DIM_Product.csv` + `Scripts/DIM_Product Cleansing.sql` | `ADVENTUREWORKS_MIGRATED.DW.DIM_PRODUCT` (+ optional joins to `DIM_PRODUCT_SUBCATEGORY` / `DIM_PRODUCT_CATEGORY`) |
| `FACT_InternetSales` | `Tables/FACT_InternetSales.csv` + `Scripts/FACT_InternetSales.sql` | `ADVENTUREWORKS_MIGRATED.DW.FACT_INTERNET_SALES` |
| Budget table (`FACT_Budget` semantics) | `Tables/SalesBudget.xlsx` | Load to `DW.FACT_BUDGET` (recommended) or keep Excel source temporarily |

---

## 4) Step-by-step repoint instructions (Power BI Desktop)

> Recommended approach: replace each SQL Server/CSV query in Power Query with Snowflake-backed queries **while keeping query names unchanged**. This preserves visuals, relationships, and DAX bindings.

1. Open `AdventureWorks Sales Performance Dashboard.pbix`.
2. Create a backup copy of the `.pbix`.
3. Go to **Home → Transform data** (Power Query Editor).
4. For each query (`DIM_Calender`, `DIM_Customer`, `DIM_Product`, `FACT_InternetSales`):
   - Open **Advanced Editor**.
   - Replace SQL Server/CSV source step with Snowflake source steps.
   - Keep the final query name exactly the same as current model name.
5. Use Snowflake connector pattern similar to:

```powerquery
let
    Source = Snowflake.Databases(
        "KLDJZPG-RTB48613.snowflakecomputing.com",
        "ADVENTUREWORKS_BI_WH",
        [Role = "ACCOUNTADMIN"]
    ),
    DB = Source{[Name="ADVENTUREWORKS_MIGRATED",Kind="Database"]}[Data],
    DW = DB{[Name="DW",Kind="Schema"]}[Data],
    DIM_CUSTOMER = DW{[Name="DIM_CUSTOMER",Kind="Table"]}[Data]
in
    DIM_CUSTOMER
```

6. Recreate source SQL shaping in Power Query where needed (renames, joins, filters), or push it down via `Value.NativeQuery(...)` on Snowflake.
7. Repoint/replace budget source:
   - Preferred: load `SalesBudget.xlsx` into Snowflake (`DW.FACT_BUDGET`) and repoint query there.
   - Temporary fallback: keep Excel source and validate measure behavior.
8. Click **Close & Apply**.
9. Go to **Model view**:
   - Verify key relationships still exist.
   - Confirm data types (date, numeric, text) are correct.
10. Refresh the model and check all 3 report pages for errors.
11. If visuals fail, use **Performance Analyzer** and Power Query diagnostics to identify broken fields or query folding issues.

---

## 5) SQL dialect conversion notes (T-SQL → Snowflake)

The source cleansing scripts use common T-SQL patterns. Convert as follows:

| T-SQL pattern (seen/expected) | Snowflake equivalent |
|---|---|
| `[ColumnName]` identifier quoting | `"COLUMNNAME"` (or unquoted uppercase identifiers) |
| `LEFT(col, 3)` | `LEFT(col, 3)` (same) |
| `ISNULL(expr, 'x')` | `COALESCE(expr, 'x')` |
| `c.firstname + ' ' + c.lastname` | `c.firstname || ' ' || c.lastname` |
| `CASE WHEN ... THEN ... END` | `CASE WHEN ... THEN ... END` (same) |
| `WHERE LEFT(OrderDateKey, 4) >= 2019` | `WHERE TO_NUMBER(SUBSTR(TO_VARCHAR(OrderDateKey),1,4)) >= 2019` |
| `GETDATE()` | `CURRENT_TIMESTAMP()` |
| `DATEDIFF(day, d1, d2)` | `DATEDIFF('day', d1, d2)` |
| `CONVERT(date, dt)` / `CAST(... AS DATE)` | `TO_DATE(dt)` / `CAST(... AS DATE)` |

Notes:

- Snowflake identifiers are case-insensitive unless quoted.
- Prefer fully-qualified objects in native SQL: `ADVENTUREWORKS_MIGRATED.DW.<TABLE>`.

---

## 6) DAX calculated fields that may need rewriting

Detected measure objects in the report:

1. `Key Measures.Sales`
2. `Key Measures.Budget Amount`
3. `Key Measures.Sales - Budget`

Potential rewrite impact when moving to Snowflake:

- If these measures depend only on model columns, DAX often remains unchanged.
- Rewrites are commonly needed when:
  - Measure logic depends on table names/columns that changed during repoint.
  - Logic was moved from DAX into source SQL views.
  - DirectQuery folding changes semantics/performance.

Practical rewrite checklist:

- `Key Measures.Sales`: confirm it still aggregates `FACT_InternetSales[SalesAmount]` correctly.
- `Key Measures.Budget Amount`: confirm new Snowflake/Excel budget table and grain match the original.
- `Key Measures.Sales - Budget`: confirm both upstream measures return compatible grain and filter context.

If translating these to Snowflake SQL views, common equivalents are:

- Sales: `SUM(fact_internet_sales.salesamount)`
- Budget: `SUM(fact_budget.budget_amount)`
- Variance: `SUM(fact_internet_sales.salesamount) - SUM(fact_budget.budget_amount)`

---

## 7) Snowflake connector parameters (Power BI)

Use the following values in Power BI Snowflake connector:

| Parameter | Value |
|---|---|
| Server | `KLDJZPG-RTB48613.snowflakecomputing.com` |
| Warehouse | `ADVENTUREWORKS_BI_WH` |
| Database | `ADVENTUREWORKS_MIGRATED` |
| Schema | `DW` |
| Role | `ACCOUNTADMIN` (or dedicated BI role) |
| Username | `dmytro` |
| Authentication | Username/password or SSO (per account policy) |

Security guidance:

- Do not hardcode credentials in PBIX parameters.
- Use least-privilege role for dashboard refresh operations.

---

## 8) Post-repoint validation checklist

1. Refresh completes with no connector/query errors.
2. All visuals render on:
   - `Sales Overview`
   - `Customer Details`
   - `Product Details`
3. Slicers (`Product Category`, `Product Color`, customer attributes) filter visuals correctly.
4. `Sales`, `Budget Amount`, and `Sales - Budget` values are non-null and plausible.
5. Row-level spot checks between Power BI and Snowflake SQL match expected results.
