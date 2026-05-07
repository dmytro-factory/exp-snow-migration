# AdventureWorks SQL Server → Snowflake Migration

## Mission Summary

This repository contains the generated artifacts for an end-to-end migration of AdventureWorksDW from SQL Server to Snowflake, including:

- source assessment and target architecture
- Snowflake DDL + Snowpark notebook artifacts
- data extraction/load SQL
- dashboard migration outputs (Power BI repoint guide + Streamlit app)
- final validation and packaging outputs

## What Was Migrated

- **Source:** `AdventureWorksDW2022` on SQL Server (`localhost:1433`)
- **Target:** `ADVENTUREWORKS_MIGRATED` in Snowflake
  - `STAGING` (raw landing tables)
  - `DW` (dimensions/facts, SCD Type 2 columns)
  - `UTILITY` (formats, task/procedure, validation support)
- **Dashboard:** Snowflake-backed Streamlit dashboard in `04-dashboard-migration/streamlit_app.py`

## Key Deliverables

- `01-assessment-report.md`
- `02-target-architecture.md`
- `snowflake-artifacts/*.sql` and `snowflake-artifacts/*.ipynb`
- `03-data-migration-scripts/`
- `04-dashboard-migration/`
- `05-validation-report.md`
- `deployment-guide.md`
- `deploy.sh`

## Deployment to Snowflake

1. Configure `.env` in repo root:
   - `SNOWFLAKE_ACCOUNT`
   - `SNOWFLAKE_USER`
   - `SNOWFLAKE_PASSWORD`
   - `SNOWFLAKE_ROLE`
2. Install dependencies:
   ```bash
   uv sync
   ```
3. Run ordered SQL deployment:
   ```bash
   ./deploy.sh --mode full
   ```
4. Run validation SQL:
   ```bash
   ./deploy.sh --mode validate
   ```

For full step-by-step instructions and a 30-minute operator workflow, see `deployment-guide.md`.

## Run the Streamlit Dashboard

```bash
source .venv/bin/activate
streamlit run 04-dashboard-migration/streamlit_app.py --server.port 3201 --server.headless true
```

Open: `http://localhost:3201`

## Validation Guide

### SQL Validation Scripts

- `snowflake-artifacts/validation_schema.sql`
- `snowflake-artifacts/validation_row_counts.sql`
- `snowflake-artifacts/validation_checksums.sql`
- `snowflake-artifacts/validation_scd_type2.sql`

Run all validation SQL in order:

```bash
./deploy.sh --mode validate
```

### Expected Result

All validation layers should report **PASS** with zero failed objects/tables/checks.  
The final validation outcomes are recorded in:

- `05-validation-report.md`
- `output/phase6/validation_results.json`
- `output/phase6/sqlserver_validation_results.json`
