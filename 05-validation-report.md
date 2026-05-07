# 05 Validation Report — AdventureWorks → Snowflake

## Scope

This report covers execution results for:

- `snowflake-artifacts/validation_schema.sql`
- `snowflake-artifacts/validation_row_counts.sql`
- `snowflake-artifacts/validation_checksums.sql`
- `snowflake-artifacts/validation_scd_type2.sql`
- SQL Server source parity checks (row counts + checksums) aligned to generated validation baselines
- Streamlit dashboard runtime verification with real Snowflake data

Execution artifacts are stored in `output/phase6/`.

## Execution Summary

| Validation Layer | Status | Evidence |
|---|---|---|
| Snowflake schema/object validation | **PASS** | `output/phase6/validation_results.json` (`validation_schema`) |
| Snowflake row-count parity (STAGING + DW) | **PASS** | `output/phase6/validation_results.json` (`validation_row_counts`) |
| Snowflake checksum parity (STAGING + DW) | **PASS** | `output/phase6/validation_results.json` (`validation_checksums`) |
| Snowflake SCD Type 2 integrity | **PASS** | `output/phase6/validation_results.json` (`validation_scd_type2`) |
| SQL Server source baseline verification | **PASS** | `output/phase6/sqlserver_validation_results.json` |
| Streamlit real-data rendering + interaction | **PASS** | screenshots in `output/phase6/` |

## Detailed Results

### 1) Schema Validation (`validation_schema.sql`)

- Overall status: **PASS**
- Failed objects: **0**
- Checked objects: **67**

Validated objects include:
- Schemas: `STAGING`, `DW`, `UTILITY`
- 31 staging tables + 28 DW tables
- `FF_CSV`, `FF_PARQUET`
- `PARQUET_INTERNAL_STAGE`
- `SP_RUN_NB_DATA_QUALITY`
- `TASK_RUN_NB_DATA_QUALITY_DAILY`

### 2) Row Count Validation (`validation_row_counts.sql`)

All scopes returned **PASS**:

| Scope | Failed | Checked |
|---|---:|---:|
| `STAGING_PARITY` | 0 | 31 |
| `DW_CURRENT_PARITY` | 0 | 17 |
| `DW_PARITY` | 0 | 11 |

### 3) Checksum Validation (`validation_checksums.sql`)

All scopes returned **PASS**:

| Scope | Failed | Checked |
|---|---:|---:|
| `STAGING_CHECKSUM` | 0 | 31 |
| `DW_CURRENT_CHECKSUM` | 0 | 17 |
| `DW_CHECKSUM` | 0 | 11 |

### 4) SCD Type 2 Integrity (`validation_scd_type2.sql`)

- Overall status: **PASS**
- Failed checks: **0**
- Total checks: **102**

Per-dimension checks passed for:
- one current row per business key
- current rows with open `_valid_to`
- expired rows with populated `_valid_to`
- no overlap between validity periods
- no gaps between validity periods
- source key coverage in current DW rows

### 5) SQL Server Source Validation (Aligned Baselines)

From `output/phase6/sqlserver_validation_results.json`:

- Row-count tables checked: **31**
- Row-count failures: **0**
- Checksum tables checked: **31**
- Checksum failures: **0**

## Streamlit Dashboard Verification

The dashboard was started on `http://localhost:3201` and validated with browser automation against live Snowflake queries.

### Evidence Screenshots

- `output/phase6/streamlit-home-annotated.png`
- `output/phase6/streamlit-category-filter-annotated.png`
- `output/phase6/streamlit-scd-product-annotated.png`

### Observed Real Data (not mock)

- Initial metrics:
  - Total Sales: **$29,358,677.22**
  - Total Profit: **$12,080,883.64**
  - Return Rate: **10.81%**
  - Active rows/orders: **60,398 / 27,659**
- After product-category filter (`Accessories`) metrics changed to:
  - Total Sales: **$700,759.96**
  - Total Profit: **$438,674.57**
  - Return Rate: **1.81%**
  - Active rows/orders: **36,092 / 18,208**
- SCD explorer interaction:
  - Dimension switched from `Customer` to `Product`
  - Business key example shown: `1 — Adjustable Race`
  - Timeline + history table rendered successfully

## Contract Assertion Coverage

| Assertion | Requirement | Status |
|---|---|---|
| `VAL-VAL-005` | Validation report generated with pass/fail by layer | **PASS** |
| `VAL-VAL-006` | Deployment guide enabling 30-minute deployment | **PASS** (`deployment-guide.md`) |
| `VAL-VAL-007` | README with mission/deploy/run/validate instructions | **PASS** (`README.md`) |
| `VAL-CROSS-001` | End-to-end migrated Snowflake warehouse validated | **PASS** |
| `VAL-CROSS-002` | Streamlit displays real migrated data | **PASS** |

## Final Status

**Overall validation status: PASS.**  
All required validation layers executed successfully, source/target parity checks passed, and the Streamlit dashboard was verified to render real migrated data with working filter and SCD interactions.
