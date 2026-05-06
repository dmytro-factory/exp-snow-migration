#!/usr/bin/env python3
"""Extract AdventureWorksDW2022 tables to Parquet files using pymssql."""

from __future__ import annotations

import argparse
import logging
import os
import re
import sys
from pathlib import Path
from typing import List, Tuple

import pandas as pd
import pymssql


LOGGER = logging.getLogger('extract_data')


def to_snake_case(value: str) -> str:
    value = re.sub(r'([A-Z]+)([A-Z][a-z])', r'\1_\2', value)
    value = re.sub(r'([a-z0-9])([A-Z])', r'\1_\2', value)
    value = re.sub(r'[^A-Za-z0-9]+', '_', value)
    return value.strip('_').lower()


def table_file_stem(schema_name: str, table_name: str) -> str:
    table_stem = to_snake_case(table_name)
    if schema_name.lower() == 'dbo':
        return table_stem
    return f"{to_snake_case(schema_name)}_{table_stem}"


def fetch_tables(connection: pymssql.Connection) -> List[Tuple[str, str]]:
    sql = """
    SELECT
      s.name AS schema_name,
      t.name AS table_name
    FROM sys.tables AS t
    INNER JOIN sys.schemas AS s
      ON t.schema_id = s.schema_id
    WHERE t.is_ms_shipped = 0
    ORDER BY s.name, t.name;
    """
    with connection.cursor() as cursor:
        cursor.execute(sql)
        return [(row[0], row[1]) for row in cursor.fetchall()]


def export_table(connection: pymssql.Connection, schema_name: str, table_name: str, output_dir: Path) -> int:
    query = f"SELECT * FROM [{schema_name}].[{table_name}]"
    LOGGER.info('Extracting %s.%s', schema_name, table_name)
    frame = pd.read_sql(query, connection)

    output_file = output_dir / f"{table_file_stem(schema_name, table_name)}.parquet"
    frame.to_parquet(output_file, index=False)
    LOGGER.info('Wrote %s rows to %s', len(frame), output_file)
    return len(frame)


def build_parser() -> argparse.ArgumentParser:
    repo_root = Path(__file__).resolve().parents[1]
    default_output = repo_root / 'output' / 'extracted-data'

    parser = argparse.ArgumentParser(description='Extract AdventureWorksDW2022 to Parquet files.')
    parser.add_argument('--host', default=os.getenv('SQLSERVER_HOST', 'localhost'))
    parser.add_argument('--port', type=int, default=int(os.getenv('SQLSERVER_PORT', '1433')))
    parser.add_argument('--user', default=os.getenv('SQLSERVER_USER', 'sa'))
    parser.add_argument('--password', default=os.getenv('SQLSERVER_PASSWORD', 'FactoryDemo2025!'))
    parser.add_argument('--database', default=os.getenv('SQLSERVER_DATABASE', 'AdventureWorksDW2022'))
    parser.add_argument('--output-dir', type=Path, default=default_output)
    return parser


def main() -> int:
    logging.basicConfig(level=logging.INFO, format='%(asctime)s [%(levelname)s] %(message)s')
    args = build_parser().parse_args()

    output_dir: Path = args.output_dir
    output_dir.mkdir(parents=True, exist_ok=True)

    LOGGER.info('Connecting to SQL Server %s:%s / %s', args.host, args.port, args.database)
    try:
        connection = pymssql.connect(
            server=args.host,
            port=args.port,
            user=args.user,
            password=args.password,
            database=args.database,
            login_timeout=15,
            timeout=300,
        )
    except Exception:
        LOGGER.exception('Failed to connect to SQL Server')
        return 1

    total_rows = 0
    tables_exported = 0
    failed_tables: List[str] = []

    try:
        tables = fetch_tables(connection)
        LOGGER.info('Discovered %s user tables for export', len(tables))

        for schema_name, table_name in tables:
            try:
                total_rows += export_table(connection, schema_name, table_name, output_dir)
                tables_exported += 1
            except Exception:
                LOGGER.exception('Failed exporting %s.%s', schema_name, table_name)
                failed_tables.append(f'{schema_name}.{table_name}')
    finally:
        connection.close()
        LOGGER.info('SQL Server connection closed')

    LOGGER.info('Export complete: %s successful tables, %s failed, %s total rows', tables_exported, len(failed_tables), total_rows)
    if failed_tables:
        LOGGER.error('Failed tables: %s', ', '.join(failed_tables))
        return 1

    return 0


if __name__ == '__main__':
    sys.exit(main())
