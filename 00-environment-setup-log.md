# Environment Setup Log

Date: 2026-05-06

## Tools Installed / Verified

| Tool | Version | Status |
|------|---------|--------|
| git | 2.50.1 | Verified |
| docker | 29.4.1 | Verified |
| docker-compose | v5.1.3 | Verified |
| python3 | 3.9.6 | Verified |
| uv | 0.11.10 | Verified |
| snowflake-connector-python | 4.4.0 | Installed via uv |
| jupyter | 1.1.1 | Installed via uv |

## Docker SQL Server

- Image: `mcr.microsoft.com/mssql/server:2022-latest`
- Container: `adventureworks-sql` (running on port 1433)
- Platform: linux/amd64 (running via Rosetta on Apple Silicon)
- SA Password: `FactoryDemo2025!`

## AdventureWorks Database

- Backup: `AdventureWorksDW2022.bak` (97.1 MB, downloaded from Microsoft SQL Server samples)
- Restored as: `AdventureWorksDW2022`
- Verification: `SELECT COUNT(*) FROM DimCustomer` returned **18,484 rows**

## Cloned Source Repositories

| Repo | Path | Contents |
|------|------|----------|
| `andrescastillol/ETL-DesignSolution` | `source/etl-repo/` | T-SQL scripts, SSIS packages |
| `RohanParkar/AdventureWorks-Sales-Performance-Dashboard` | `source/dashboard-repo/` | Power BI `.pbix`, CSV tables, screenshots |

## Network Connectivity

- Docker SQL Server: `localhost:1433` — **Connected** (DimCustomer: 18,484 rows)
- Snowflake account: `KLDJZPG-RTB48613` — **Connected**
  - Version: 10.16.101
  - User: DMYTRO
  - Role: ACCOUNTADMIN

## Issues / Notes

- None. Environment is ready for Part 2 (Migration Mission).
