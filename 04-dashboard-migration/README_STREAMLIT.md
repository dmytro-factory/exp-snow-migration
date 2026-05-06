# AdventureWorks Streamlit Dashboard

This Streamlit app connects directly to Snowflake (`ADVENTUREWORKS_MIGRATED.DW`) and renders:

- Sales KPIs (total sales, total profit, return rate)
- Sales trend line chart
- Top products bar chart
- Geographic sales map
- Customer segment pie chart
- SCD Type 2 history explorer

## Local run

1. Ensure the project `.env` contains:
   - `SNOWFLAKE_ACCOUNT`
   - `SNOWFLAKE_USER`
   - `SNOWFLAKE_PASSWORD`
   - Optional: `SNOWFLAKE_ROLE`, `SNOWFLAKE_WAREHOUSE`, `SNOWFLAKE_DATABASE`
2. Install dependencies:
   ```bash
   uv pip install -r 04-dashboard-migration/requirements.txt
   ```
3. Run:
   ```bash
   streamlit run 04-dashboard-migration/streamlit_app.py --server.port 3201 --server.headless true
   ```
4. Open `http://localhost:3201`.

## Docker run

Build from the repository root:

```bash
docker build -f 04-dashboard-migration/Dockerfile -t adventureworks-streamlit .
```

Run (passing Snowflake env variables):

```bash
docker run --rm -p 3201:3201 \
  -e SNOWFLAKE_ACCOUNT \
  -e SNOWFLAKE_USER \
  -e SNOWFLAKE_PASSWORD \
  -e SNOWFLAKE_ROLE \
  -e SNOWFLAKE_WAREHOUSE \
  -e SNOWFLAKE_DATABASE \
  adventureworks-streamlit
```
