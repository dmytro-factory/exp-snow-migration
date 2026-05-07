# Mission Completion Report: AdventureWorks → Snowflake Migration

**Mission:** Automated Migration from Microsoft AdventureWorks/SQL Server to Snowflake  
**Date:** 2026-05-06/07  
**Status:** Complete — All 39/39 validation assertions passed  
**Repository:** https://github.com/dmytro-factory/exp-snow-migration

---

## Executive Summary

This mission successfully automated the end-to-end migration of the Microsoft AdventureWorks data warehouse stack (SQL Server + SSIS + Power BI) into Snowflake using **Snowpark Notebooks** as the target primitive. The migration was executed against a live Snowflake account (`KLDJZPG-RTB48613`) with full data extraction, loading, validation, and dashboard repointing/rebuilding — all verified through automated validation.

**Key Metrics:**
- **39/39** validation assertions passed across **7 sealed milestones**
- **1,060,820 rows** extracted from SQL Server AdventureWorksDW2022 to Snowflake
- **0.00% row count difference** between source and target (31 staging + 28 DW tables)
- **67/67** schema objects verified in Snowflake
- **102/102** SCD Type 2 integrity checks passed

---

## Milestone 1: Discovery & Assessment

- Parsed ETL repository (`andrescastillol/ETL-DesignSolution`) and dashboard repository (`RohanParkar/AdventureWorks-Sales-Performance-Dashboard`)
- Identified all artifact types: T-SQL scripts, Power BI `.pbix`, CSV tables, screenshots
- Built structured inventory of **48 migration objects** with metadata (name, type, complexity, dependencies)
- Applied complexity scoring: **23 Simple / 16 Medium / 9 Complex**
- **Deliverable:** `01-assessment-report.md`
- **Validation:** 4/4 assertions passed (VAL-DISC-001 through VAL-DISC-004)

---

## Milestone 2: Target Architecture Design

- Designed three-schema target layout:
  - `STAGING` — raw loaded data (mirrors source)
  - `DW` — star schema dimensions and facts with SCD Type 2 support
  - `UTILITY` — validation tables, UDFs, metadata
- Mapped all 48+ source objects to Snowpark Notebook primitives
- Documented SQL Server → Snowflake data type mappings
- Designed scheduled Snowpark notebook task mapped to Snowflake Task with cron `0 2 * * * UTC` (SUSPENDED state)
- **Deliverable:** `02-target-architecture.md` with Mermaid diagrams
- **Validation:** 5/5 assertions passed (VAL-ARCH-001 through VAL-ARCH-005)

---

## Milestone 3: DDL Generation & Deployment

- Generated 5 DDL scripts in dependency order:
  - `01_create_databases.sql` — database, schemas, warehouses
  - `02_create_staging_tables.sql` — 31 raw staging tables
  - `03_create_dw_tables.sql` — 28 star schema tables with SCD Type 2 columns (`_valid_from`, `_valid_to`, `_is_current`)
  - `04_create_file_formats.sql` — CSV + Parquet formats
  - `05_create_stages.sql` — internal stage definitions
- Deployed all scripts to live Snowflake account
- Verified via `INFORMATION_SCHEMA`: 0 compilation errors
- **Deliverable:** `snowflake-artifacts/*.sql`
- **Validation:** 4/4 assertions passed (VAL-DDL-001 through VAL-DDL-004)

---

## Milestone 4: Snowpark Notebooks

- Generated and executed 3 Snowpark Python notebooks:
  - `notebook_scd_type2.ipynb` — MERGE logic for SCD Type 2 dimension loads
  - `notebook_data_quality.ipynb` — row count, null, duplicate checks
  - `notebook_load_staging.ipynb` — CSV/Parquet stage-to-STAGING loading
- Created scheduled Snowflake Task `TASK_RUN_NB_DATA_QUALITY_DAILY` with cron schedule, left in **SUSPENDED** state
- All notebook cells executed via `jupyter nbconvert --execute` without errors
- **Deliverable:** `snowflake-artifacts/*.ipynb` + task SQL
- **Validation:** 4/4 assertions passed (VAL-NB-001 through VAL-NB-004)

---

## Milestone 5: Data Migration

- **Extraction:** `extract_data.py` using `pymssql` extracted all 31 tables from Docker SQL Server (`localhost:1433`) → Parquet files in `output/extracted-data/`
  - **1,060,820 total rows** exported
- **Upload:** All Parquet files uploaded to Snowflake internal stage via `PUT`
- **Staging Load:** `load_staging.sql` with `COPY INTO` for all 31 tables
- **DW Load:** `load_dw.sql` with `MERGE` statements handling SCD Type 2 logic for all dimension tables
- **Issue Resolved:** Binary column Parquet load failures fixed by setting `BINARY_AS_TEXT=FALSE` on file format
- **Validation:** 7/7 assertions passed (VAL-DATA-001 through VAL-DATA-007)
  - **Row count parity: 0.00% diff** across all 31 staging + 28 DW tables

---

## Milestone 6: Dashboard Migration

### A. Power BI Repointing Guide
- Analyzed Power BI `.pbix` file structure, connection strings, DAX measures
- Generated step-by-step SQL Server → Snowflake repointing instructions
- Documented SQL dialect conversions (T-SQL → Snowflake SQL)
- Listed DAX calculated fields requiring rewrite
- **Deliverable:** `04-dashboard-migration/dashboard-repoint-guide.md`

### B. Streamlit Dashboard (Factory AI Styled)
- Built `streamlit_app.py` with **Factory AI visual identity**:
  - Dark base theme (#0A0A0A)
  - Warm orange accent (#FF6B35)
  - Geist typography, schematic line motifs
- 6 visualizations querying live Snowflake DW:
  1. Sales KPIs (Total Sales: $29,358,677.22, Profit: $12,080,883.64, Return Rate: 10.81%)
  2. Sales trend line chart (time series)
  3. Top products bar chart
  4. Geographic sales choropleth map
  5. Customer segment pie chart
  6. SCD Type 2 history explorer
- Interactive filters: date range, product category, region
- Verified via `agent-browser` with screenshots showing real migrated data
- **Deliverables:** `streamlit_app.py`, `requirements.txt`, `Dockerfile`, `README_STREAMLIT.md`

### C. Comparison Report
- Compared repoint effort vs rebuild effort
- Feature parity matrix: Power BI vs Streamlit
- Snowflake-native advantages of Streamlit highlighted
- Clear recommendation provided
- **Deliverable:** `04-dashboard-migration/dashboard-comparison-report.md`

- **Validation:** 6/6 assertions passed (VAL-DASH-001 through VAL-DASH-006)

---

## Milestone 7: Validation & Packaging

### Validation Scripts (All Passed)
- `validation_schema.sql` — **67/67 objects** verified in Snowflake
- `validation_row_counts.sql` — **STAGING/DW/DW_CURRENT all PASS** (0.00% diff)
- `validation_checksums.sql` — **All checksum scopes PASS**
- `validation_scd_type2.sql` — **102/102 checks PASS** (0 failures)
  - Current row integrity: exactly one current row per key
  - Period continuity: no gaps or overlaps
  - Source coverage: every source key has a current DW record

### Final Deliverables
- `05-validation-report.md` — comprehensive pass/fail report for all 6 validation layers
- `README.md` — mission summary, deployment, run, and validation guides
- `deployment-guide.md` — step-by-step human deployment within 30 minutes
- `deploy.sh` — automated SQL deployment in dependency order (supports `--dry-run` and `--mode validate`)
- `output/phase7/adventureworks-snowflake-deliverable.zip` — packaged deliverable (941KB)

- **Validation:** 9/9 assertions passed (VAL-VAL-001 through VAL-VAL-007 + VAL-CROSS-001 + VAL-CROSS-002)

---

## Technical Environment

| Component | Details |
|-----------|---------|
| Source Database | Docker SQL Server `adventureworks-sql` on `localhost:1433` |
| Source DB | `AdventureWorksDW2022` (restored from `.bak`) |
| Target Snowflake | Account `KLDJZPG-RTB48613`, Version 10.16.101 |
| Target Database | `ADVENTUREWORKS_MIGRATED` |
| Schemas | `STAGING`, `DW`, `UTILITY` |
| Python | 3.14.4 in `.venv`, managed via `uv` |
| Key Packages | snowflake-connector-python 4.4.0, pymssql 2.3.13, streamlit 1.57.0, pandas 3.0.2, plotly 6.7.0, jupyter 1.1.1, pyarrow 24.0.0 |
| SQL Server Driver | `pymssql` (macOS — Microsoft ODBC unreliable on ARM64) |

---

## Known Pre-Existing Notes

- The cloned ETL repository (`andrescastillol/ETL-DesignSolution`) contains T-SQL scripts but **no `.dtsx` SSIS package files**. The assessment report handles this by using SQL script analysis for transformation mapping.
- Docker SQL Server runs `linux/amd64` image via Rosetta emulation on Apple Silicon.

---

## Mission Success Criteria — All Met

| Criterion | Status |
|-----------|--------|
| All source objects inventoried | ✅ 48 objects with complexity scoring |
| Snowflake artifacts generated for every object | ✅ 31 staging + 28 DW tables, 3 notebooks, UDFs, tasks |
| At least one data validation test passes | ✅ Schema (67/67), Row counts (0% diff), Checksums (PASS), SCD (102/102) |
| Streamlit dashboard runs with Snowflake data | ✅ Verified via agent-browser with real $29M+ sales data |
| Validation Report with pass/fail per layer | ✅ `05-validation-report.md` |
| Human deployable within 30 minutes | ✅ `deployment-guide.md` + `deploy.sh` |

---

*End of Report*
