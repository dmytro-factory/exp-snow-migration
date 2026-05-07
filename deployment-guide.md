# Deployment Guide (30-Minute Operator Runbook)

## Goal

Deploy the AdventureWorks migration artifacts into a Snowflake account, run validation scripts, and launch the Streamlit dashboard.

---

## Estimated Timeline

| Phase | Time |
|---|---:|
| Environment + credentials | 5 min |
| SQL deployment (DDL + load SQL) | 10 min |
| Validation execution | 5 min |
| Streamlit verification | 5–10 min |
| **Total** | **25–30 min** |

---

## Prerequisites

- macOS/Linux shell with:
  - Python 3.9+
  - `uv`
  - access to SQL Server source (`localhost:1433`) if re-extracting data
- Snowflake credentials with object-creation and data-load permissions
- Repository checked out at:
  - `/Users/dy/Documents/Sandbox/exp-snow-migration`

---

## 1) Configure Credentials (2–3 min)

Create/update `.env` in repo root:

```bash
SNOWFLAKE_ACCOUNT=<your_account>
SNOWFLAKE_USER=<your_user>
SNOWFLAKE_PASSWORD=<your_password>
SNOWFLAKE_ROLE=ACCOUNTADMIN
```

---

## 2) Install Python Dependencies (2–3 min)

```bash
uv sync
```

---

## 3) (Optional) Re-Extract Source Data (5–8 min)

If `output/extracted-data/` is missing or stale:

```bash
source .venv/bin/activate
python 03-data-migration-scripts/extract_data.py
```

---

## 4) Upload Extracted Files to Snowflake Stage (5 min)

Use a Python connector upload loop:

```bash
source .venv/bin/activate
python - <<'PY'
import os
from pathlib import Path
import snowflake.connector

root = Path("/Users/dy/Documents/Sandbox/exp-snow-migration")
for line in (root / ".env").read_text().splitlines():
    if "=" in line and not line.strip().startswith("#"):
        k, v = line.split("=", 1)
        os.environ[k.strip()] = v.strip().strip('"').strip("'")

conn = snowflake.connector.connect(
    account=os.environ["SNOWFLAKE_ACCOUNT"],
    user=os.environ["SNOWFLAKE_USER"],
    password=os.environ["SNOWFLAKE_PASSWORD"],
    role=os.environ.get("SNOWFLAKE_ROLE", "ACCOUNTADMIN"),
    warehouse=os.environ.get("SNOWFLAKE_WAREHOUSE", "COMPUTE_WH"),
)
cur = conn.cursor()
cur.execute("USE DATABASE ADVENTUREWORKS_MIGRATED")
cur.execute("USE SCHEMA STAGING")
folder = root / "output" / "extracted-data"
for f in sorted(folder.glob("*.parquet")) + sorted(folder.glob("*.csv")):
    cur.execute(f"PUT file://{f} @ADVENTUREWORKS_MIGRATED.STAGING.PARQUET_INTERNAL_STAGE AUTO_COMPRESS=FALSE OVERWRITE=TRUE")
print("Upload complete.")
cur.close()
conn.close()
PY
```

---

## 5) Run Ordered SQL Deployment (5–10 min)

Make sure script is executable:

```bash
chmod +x deploy.sh
```

Deploy in dependency order (DDL + load SQL):

```bash
./deploy.sh --mode full
```

Dry-run deployment order without execution:

```bash
./deploy.sh --mode full --dry-run
```

---

## 6) Execute Validation Layer (3–5 min)

```bash
./deploy.sh --mode validate
```

This runs:

1. `validation_schema.sql`
2. `validation_row_counts.sql`
3. `validation_checksums.sql`
4. `validation_scd_type2.sql`

Expected result: all layers return `PASS`.

---

## 7) Launch and Verify Streamlit (3–5 min)

```bash
source .venv/bin/activate
streamlit run 04-dashboard-migration/streamlit_app.py --server.port 3201 --server.headless true
```

Open `http://localhost:3201` and confirm:

- KPI cards render with non-zero values
- filters (date/category/region) update visuals
- SCD Type 2 explorer loads timeline/history rows

---

## 8) Final Deliverables Checklist

- `README.md`
- `deployment-guide.md`
- `05-validation-report.md`
- `deploy.sh`
- `output/phase6/*` (validation JSON + Streamlit evidence)
- `output/phase7/adventureworks-snowflake-deliverable.zip` (packaged deliverable)

---

## Troubleshooting

- **Snowflake auth failures:** verify `.env` values and role privileges.
- **`load_staging.sql` UTF8/BINARY issue:** set `BINARY_AS_TEXT = FALSE` on `UTILITY.ff_parquet`.
- **Empty Streamlit visuals:** confirm DW tables are populated and filters are not excluding all rows.
- **Validation failures:** inspect `05-validation-report.md` + `output/phase6/*.json` for failed scope/table/check details.
