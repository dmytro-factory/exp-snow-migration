#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="ddl"
DRY_RUN="false"

usage() {
  cat <<'EOF'
Usage: ./deploy.sh [--mode ddl|full|validate] [--dry-run]

Modes:
  ddl       Run core Snowflake DDL scripts only (default)
  full      Run DDL + load_staging.sql + load_dw.sql
  validate  Run validation scripts only

Examples:
  ./deploy.sh --mode ddl
  ./deploy.sh --mode full
  ./deploy.sh --mode validate
  ./deploy.sh --mode full --dry-run
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --dry-run)
      DRY_RUN="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

declare -a SQL_FILES=()

case "$MODE" in
  ddl)
    SQL_FILES=(
      "snowflake-artifacts/01_create_databases.sql"
      "snowflake-artifacts/02_create_staging_tables.sql"
      "snowflake-artifacts/03_create_dw_tables.sql"
      "snowflake-artifacts/04_create_file_formats.sql"
      "snowflake-artifacts/05_create_stages.sql"
      "snowflake-artifacts/06_create_data_quality_notebook_task.sql"
    )
    ;;
  full)
    SQL_FILES=(
      "snowflake-artifacts/01_create_databases.sql"
      "snowflake-artifacts/02_create_staging_tables.sql"
      "snowflake-artifacts/03_create_dw_tables.sql"
      "snowflake-artifacts/04_create_file_formats.sql"
      "snowflake-artifacts/05_create_stages.sql"
      "snowflake-artifacts/06_create_data_quality_notebook_task.sql"
      "03-data-migration-scripts/load_staging.sql"
      "03-data-migration-scripts/load_dw.sql"
    )
    ;;
  validate)
    SQL_FILES=(
      "snowflake-artifacts/validation_schema.sql"
      "snowflake-artifacts/validation_row_counts.sql"
      "snowflake-artifacts/validation_checksums.sql"
      "snowflake-artifacts/validation_scd_type2.sql"
    )
    ;;
  *)
    echo "Invalid mode: $MODE"
    usage
    exit 1
    ;;
esac

echo "Deployment mode: $MODE"
echo "Root directory: $ROOT_DIR"
echo "Execution order:"
for f in "${SQL_FILES[@]}"; do
  echo "  - $f"
done

if [[ "$DRY_RUN" == "true" ]]; then
  echo "Dry run complete. No SQL executed."
  exit 0
fi

PYTHON_BIN="$ROOT_DIR/.venv/bin/python"
if [[ ! -x "$PYTHON_BIN" ]]; then
  PYTHON_BIN="python3"
fi

if [[ ! -f "$ROOT_DIR/.env" ]]; then
  echo "Missing $ROOT_DIR/.env with Snowflake credentials."
  exit 1
fi

for relative_path in "${SQL_FILES[@]}"; do
  sql_path="$ROOT_DIR/$relative_path"
  if [[ ! -f "$sql_path" ]]; then
    echo "Missing SQL file: $sql_path"
    exit 1
  fi

  echo "Running: $relative_path"
  "$PYTHON_BIN" - "$ROOT_DIR" "$sql_path" <<'PY'
import os
import sys
from pathlib import Path
import snowflake.connector

root_dir = Path(sys.argv[1])
sql_file = Path(sys.argv[2])

env_values = {}
for line in (root_dir / ".env").read_text().splitlines():
    line = line.strip()
    if not line or line.startswith("#") or "=" not in line:
        continue
    k, v = line.split("=", 1)
    env_values[k.strip()] = v.strip().strip('"').strip("'")

required = ["SNOWFLAKE_ACCOUNT", "SNOWFLAKE_USER", "SNOWFLAKE_PASSWORD"]
missing = [k for k in required if not env_values.get(k)]
if missing:
    raise SystemExit(f"Missing required .env entries: {', '.join(missing)}")

conn = snowflake.connector.connect(
    account=env_values["SNOWFLAKE_ACCOUNT"],
    user=env_values["SNOWFLAKE_USER"],
    password=env_values["SNOWFLAKE_PASSWORD"],
    role=env_values.get("SNOWFLAKE_ROLE", "ACCOUNTADMIN"),
    warehouse=env_values.get("SNOWFLAKE_WAREHOUSE", "COMPUTE_WH"),
)

try:
    sql_text = sql_file.read_text()
    statement_count = 0
    for cursor in conn.execute_string(sql_text):
        statement_count += 1
        if cursor.description:
            _ = cursor.fetchall()
    print(f"Executed {statement_count} statement(s) from {sql_file.name}")
finally:
    conn.close()
PY
done

echo "Deployment completed successfully."
