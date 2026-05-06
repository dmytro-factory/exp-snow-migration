# Repository Guidelines

This repository automates end-to-end migration of the Microsoft AdventureWorks data warehouse stack (SQL Server + SSIS + Power BI/Tableau) into Snowflake.

## Project Structure

- `mission-spec.md` — Mission specification and workflow definitions
- `source/` — Cloned source repositories (ETL + dashboard repos)
  - `source/etl-repo/` — SSIS packages, T-SQL scripts, and ETL artifacts
  - `source/dashboard-repo/` — Power BI (`.pbix`) or Tableau (`.twbx`) files
- `output/` — Generated migration artifacts organized by phase
  - `output/phase{1..7}/` — Assessment reports, architecture docs, SQL scripts, notebooks, Streamlit app, and validation reports
- `snowflake-artifacts/` — Generated `.sql`, `.ipynb`, and `.json` files for deployment
- `03-data-migration-scripts/` — Extraction and loading scripts (Python + SQL)
- `04-dashboard-migration/` — Repoint guide, Streamlit app, and comparison report

## Build, Test, and Development Commands

- `python3 extract_data.py` — Extract data from Docker SQL Server (`localhost:1433`) into Parquet/CSV
- `uv sync` or `uv pip install -r requirements.txt` — Install Python dependencies via UV (Streamlit, Snowflake connectors, pandas, plotly)
- `streamlit run streamlit_app.py` — Run the generated dashboard locally
- `make deploy` or `./deploy.sh` — Deploy generated SQL artifacts to Snowflake in dependency order
- `docker-compose up` — Start the SQL Server + AdventureWorks container (Part 1 prerequisite)

## Coding Style & Naming Conventions

- Indent with 2 spaces for SQL and YAML; 4 spaces for Python
- SQL file naming: `NN_description.sql` (e.g., `01_create_databases.sql`)
- Table names: snake_case; SCD columns prefixed with `_` (e.g., `_valid_from`, `_valid_to`, `_is_current`)
- Python scripts: snake_case filenames, type hints where practical
- All generated SQL targets Snowflake dialect (no T-SQL specific functions)

## Testing Guidelines

- Validate by running generated Snowflake scripts in a test warehouse before production deployment
- Row count and checksum validation scripts are generated automatically (`validation_row_counts.sql`, `validation_checksums.sql`)
- Streamlit dashboard should be verified manually for data load and visual correctness

## Commit & Pull Request Guidelines

- Commit messages should be imperative and concise (e.g., `Generate SCD Type 2 MERGE statements for DimCustomer`)
- Each phase produces a discrete set of artifacts — commit per phase when possible
- PRs must include the relevant `0X-report.md` output to show what was generated
- For live deployments, include `04-execution-log.md` with deployment summary

## Agent-Specific Instructions

- This project follows a two-part execution model: Part 1 (environment setup) must complete before Part 2 (migration mission) begins
- The mission is designed to run end-to-end in under 60 minutes on a representative AdventureWorks subset
- Interactive user confirmations are required between phases (see workflow diagram in `mission-spec.md`)
- If no Snowflake account is provided, generate files only and produce a human-readable `deployment-guide.md`
