#!/usr/bin/env python3
"""Deploy Jupyter notebooks to Snowflake as SiS (Notebook in Snowflake) objects."""

import json
import os
import sys

import snowflake.connector

# ---------------------------------------------------------------------------
# Load credentials from .env
# ---------------------------------------------------------------------------
ENV_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), ".env")

def load_env(path: str) -> dict:
    env = {}
    with open(path, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if "=" in line:
                key, value = line.split("=", 1)
                env[key] = value
    return env

env = load_env(ENV_PATH)

ACCOUNT = env["SNOWFLAKE_ACCOUNT"]
USER = env["SNOWFLAKE_USER"]
PASSWORD = env["SNOWFLAKE_PASSWORD"]
ROLE = env.get("SNOWFLAKE_ROLE", "ACCOUNTADMIN")
DATABASE = "ADVENTUREWORKS_MIGRATED"
SCHEMA = "UTILITY"
WAREHOUSE = "ADVENTUREWORKS_ETL_WH"

NOTEBOOKS = [
    "notebook_scd_type2.ipynb",
    "notebook_data_quality.ipynb",
    "notebook_load_staging.ipynb",
]

STAGE_NAME = f"{DATABASE}.{SCHEMA}.NOTEBOOK_STAGE"

# ---------------------------------------------------------------------------
# Connect to Snowflake
# ---------------------------------------------------------------------------
ctx = snowflake.connector.connect(
    account=ACCOUNT,
    user=USER,
    password=PASSWORD,
    role=ROLE,
    warehouse=WAREHOUSE,
    database=DATABASE,
    schema=SCHEMA,
)
cs = ctx.cursor()

# ---------------------------------------------------------------------------
# 1. Create stage if not exists
# ---------------------------------------------------------------------------
print(f"Creating stage {STAGE_NAME} ...")
cs.execute(f"CREATE STAGE IF NOT EXISTS {STAGE_NAME};")
print("Stage ready.")

# ---------------------------------------------------------------------------
# 2. Upload notebooks to stage
# ---------------------------------------------------------------------------
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

for nb in NOTEBOOKS:
    local_path = os.path.join(BASE_DIR, nb)
    print(f"Uploading {nb} to stage ...")
    # PUT with overwrite, auto_compress=false to keep .ipynb extension
    put_sql = f"PUT file://{local_path} @{STAGE_NAME} OVERWRITE = TRUE AUTO_COMPRESS = FALSE;"
    cs.execute(put_sql)
    print(f"  -> {nb} uploaded.")

# List stage contents to verify paths
print("\nStage contents:")
cs.execute(f"LIST @{STAGE_NAME}")
for row in cs.fetchall():
    print(f"  {row}")

# ---------------------------------------------------------------------------
# 3. Create NOTEBOOK objects
# ---------------------------------------------------------------------------
results = {}

for nb in NOTEBOOKS:
    notebook_name = nb.replace(".ipynb", "")
    sql = f"""
    CREATE OR REPLACE NOTEBOOK {DATABASE}.{SCHEMA}.{notebook_name}
    FROM @{STAGE_NAME}
    MAIN_FILE = '{nb}'
    QUERY_WAREHOUSE = '{WAREHOUSE}';
    """
    print(f"Creating notebook {DATABASE}.{SCHEMA}.{notebook_name} ...")
    try:
        cs.execute(sql)
        results[notebook_name] = {"status": "SUCCESS", "error": None}
        print(f"  -> SUCCESS")
    except Exception as e:
        results[notebook_name] = {"status": "FAILED", "error": str(e)}
        print(f"  -> FAILED: {e}")

# ---------------------------------------------------------------------------
# 4. Verify via INFORMATION_SCHEMA
# ---------------------------------------------------------------------------
print("\nVerifying notebooks in INFORMATION_SCHEMA...")
cs.execute(f"""
    SELECT NOTEBOOK_NAME, CREATED, LAST_ALTERED
    FROM {DATABASE}.INFORMATION_SCHEMA.NOTEBOOKS
    WHERE NOTEBOOK_SCHEMA = '{SCHEMA}'
""")
rows = cs.fetchall()
print(f"Found {len(rows)} notebook(s) in {DATABASE}.{SCHEMA}:")
for row in rows:
    print(f"  - {row[0]} | created: {row[1]} | altered: {row[2]}")

# ---------------------------------------------------------------------------
# 5. Also check NOTEBOOK_VERSIONS for main_file mapping (if available)
# ---------------------------------------------------------------------------
try:
    cs.execute(f"""
        SELECT NOTEBOOK_NAME, MAIN_FILE, LAST_ALTERED
        FROM {DATABASE}.INFORMATION_SCHEMA.NOTEBOOK_VERSIONS
        WHERE NOTEBOOK_SCHEMA = '{SCHEMA}'
    """)
    vrows = cs.fetchall()
    print(f"\nNotebook versions:")
    for row in vrows:
        print(f"  - {row[0]} | main_file: {row[1]} | altered: {row[2]}")
except Exception as e:
    print(f"\n(NOTEBOOK_VERSIONS view not accessible: {e})")

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------
cs.close()
ctx.close()

# Summary
print("\n" + "=" * 60)
print("DEPLOYMENT SUMMARY")
print("=" * 60)
for name, info in results.items():
    icon = "✅" if info["status"] == "SUCCESS" else "❌"
    print(f"{icon} {name}: {info['status']}")
    if info["error"]:
        print(f"   Error: {info['error']}")

# Return JSON for programmatic consumption
print("\n" + json.dumps(results, indent=2))
sys.exit(0 if all(r["status"] == "SUCCESS" for r in results.values()) else 1)
