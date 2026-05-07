#!/usr/bin/env python3
"""Factory-styled AdventureWorks dashboard backed by Snowflake.

Uses only streamlit native charts + pandas to avoid external chart
dependency issues in Streamlit in Snowflake runtime.
"""

from __future__ import annotations

import os
from pathlib import Path

import pandas as pd
import snowflake.connector
import streamlit as st

ORANGE = "#FF6B35"
BG = "#0A0A0A"
CARD = "#151515"
TEXT = "#F5F5F5"
MUTED = "#A0A0A0"


def load_env_file() -> None:
    env_path = Path(__file__).resolve().parents[1] / ".env"
    if not env_path.exists():
        return
    for line in env_path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        os.environ.setdefault(key.strip(), value.strip().strip('"').strip("'"))


def get_setting(name: str, default: str | None = None) -> str | None:
    if name in os.environ:
        return os.environ[name]
    try:
        if name in st.secrets:
            return str(st.secrets[name])
    except Exception:
        pass
    return default


@st.cache_resource(show_spinner=False)
def get_connection() -> snowflake.connector.SnowflakeConnection:
    try:
        from snowflake.snowpark.context import get_active_session

        session = get_active_session()
        return session.connection
    except Exception:
        pass

    load_env_file()
    account = get_setting("SNOWFLAKE_ACCOUNT")
    user = get_setting("SNOWFLAKE_USER")
    password = get_setting("SNOWFLAKE_PASSWORD")
    missing = [name for name, value in [("SNOWFLAKE_ACCOUNT", account), ("SNOWFLAKE_USER", user), ("SNOWFLAKE_PASSWORD", password)] if not value]
    if missing:
        raise RuntimeError(f"Missing Snowflake settings: {', '.join(missing)}")

    return snowflake.connector.connect(
        account=account,
        user=user,
        password=password,
        role=get_setting("SNOWFLAKE_ROLE", "ACCOUNTADMIN"),
        warehouse=get_setting("SNOWFLAKE_WAREHOUSE", "ADVENTUREWORKS_ETL_WH"),
        database=get_setting("SNOWFLAKE_DATABASE", "ADVENTUREWORKS_MIGRATED"),
        schema="DW",
        session_parameters={"PYTHON_CONNECTOR_QUERY_RESULT_FORMAT": "JSON"},
    )


@st.cache_data(ttl=300, show_spinner=False)
def fetch_dataframe(query: str) -> pd.DataFrame:
    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(query)
        rows = cursor.fetchall()
        columns = [c[0].lower() for c in cursor.description]
        return pd.DataFrame(rows, columns=columns)
    finally:
        cursor.close()


def apply_factory_theme() -> None:
    st.set_page_config(page_title="AdventureWorks | Factory Dashboard", layout="wide")
    st.markdown(
        f"""
        <style>
          @import url('https://fonts.googleapis.com/css2?family=Geist:wght@400;500;600;700&display=swap');
          .stApp {{
            background:
              radial-gradient(circle at 20% 10%, rgba(255,107,53,0.12), transparent 35%),
              radial-gradient(circle at 80% 90%, rgba(255,107,53,0.09), transparent 30%),
              repeating-linear-gradient(-45deg, rgba(255,255,255,0.03), rgba(255,255,255,0.03) 1px, transparent 1px, transparent 18px),
              {BG};
            color: {TEXT};
            font-family: 'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
          }}
          h1, h2, h3 {{
            color: {TEXT};
            letter-spacing: .01em;
          }}
          div[data-testid="stMetric"] {{
            background: {CARD};
            border: 1px solid rgba(255,107,53,.35);
            border-radius: 12px;
            padding: 10px 14px;
          }}
          .factory-banner {{
            border: 1px solid rgba(255,107,53,.55);
            border-radius: 12px;
            background: linear-gradient(90deg, rgba(255,107,53,.18), rgba(0,0,0,.25));
            padding: 12px 16px;
            margin-bottom: 12px;
          }}
          .factory-caption {{
            color: {MUTED};
            font-size: 0.92rem;
          }}
        </style>
        """,
        unsafe_allow_html=True,
    )


SALES_BASE_QUERY = """
SELECT
  TO_DATE(TO_VARCHAR(f.OrderDateKey), 'YYYYMMDD') AS order_date,
  f.SalesOrderNumber AS sales_order_number,
  f.SalesAmount AS sales_amount,
  f.TotalProductCost AS total_product_cost,
  f.OrderQuantity AS order_quantity,
  COALESCE(p.EnglishProductName, 'Unknown') AS product_name,
  COALESCE(pc.EnglishProductCategoryName, 'Uncategorized') AS product_category,
  COALESCE(st.SalesTerritoryRegion, 'Unknown') AS region,
  COALESCE(st.SalesTerritoryCountry, 'Unknown') AS country,
  COALESCE(c.EnglishOccupation, 'Unknown') AS customer_segment
FROM ADVENTUREWORKS_MIGRATED.DW.fact_internet_sales f
LEFT JOIN ADVENTUREWORKS_MIGRATED.DW.dim_product p
  ON f.ProductKey = p.ProductKey AND p._is_current = TRUE
LEFT JOIN ADVENTUREWORKS_MIGRATED.DW.dim_product_subcategory psc
  ON p.ProductSubcategoryKey = psc.ProductSubcategoryKey AND psc._is_current = TRUE
LEFT JOIN ADVENTUREWORKS_MIGRATED.DW.dim_product_category pc
  ON psc.ProductCategoryKey = pc.ProductCategoryKey AND pc._is_current = TRUE
LEFT JOIN ADVENTUREWORKS_MIGRATED.DW.dim_sales_territory st
  ON f.SalesTerritoryKey = st.SalesTerritoryKey AND st._is_current = TRUE
LEFT JOIN ADVENTUREWORKS_MIGRATED.DW.dim_customer c
  ON f.CustomerKey = c.CustomerKey AND c._is_current = TRUE
WHERE f.OrderDateKey IS NOT NULL;
"""

RETURN_ORDERS_QUERY = """
SELECT DISTINCT r.SalesOrderNumber AS sales_order_number
FROM ADVENTUREWORKS_MIGRATED.DW.fact_internet_sales_reason r
JOIN ADVENTUREWORKS_MIGRATED.DW.dim_sales_reason sr
  ON r.SalesReasonKey = sr.SalesReasonKey AND sr._is_current = TRUE
WHERE LOWER(COALESCE(sr.SalesReasonName, '')) IN ('quality', 'manufacturer', 'review');
"""

SCD_DIMENSIONS: dict[str, dict[str, str]] = {
    "Customer": {
        "table": "ADVENTUREWORKS_MIGRATED.DW.dim_customer",
        "key": "CustomerKey",
        "label": "COALESCE(FirstName || ' ' || LastName, CustomerAlternateKey, TO_VARCHAR(CustomerKey))",
    },
    "Product": {
        "table": "ADVENTUREWORKS_MIGRATED.DW.dim_product",
        "key": "ProductKey",
        "label": "COALESCE(EnglishProductName, ProductAlternateKey, TO_VARCHAR(ProductKey))",
    },
    "Geography": {
        "table": "ADVENTUREWORKS_MIGRATED.DW.dim_geography",
        "key": "GeographyKey",
        "label": "COALESCE(City || ', ' || EnglishCountryRegionName, TO_VARCHAR(GeographyKey))",
    },
    "Sales Territory": {
        "table": "ADVENTUREWORKS_MIGRATED.DW.dim_sales_territory",
        "key": "SalesTerritoryKey",
        "label": "COALESCE(SalesTerritoryRegion || ' - ' || SalesTerritoryCountry, TO_VARCHAR(SalesTerritoryKey))",
    },
}


@st.cache_data(ttl=300, show_spinner=False)
def fetch_scd_history(table: str, key_col: str, label_expr: str) -> pd.DataFrame:
    query = f"""
      SELECT
        {key_col} AS business_key,
        {label_expr} AS record_label,
        _valid_from,
        _valid_to,
        _is_current
      FROM {table}
      ORDER BY business_key, _valid_from;
    """
    return fetch_dataframe(query)


def render_dashboard() -> None:
    apply_factory_theme()
    st.markdown("<div class='factory-banner'><h2 style='margin:0;'>AdventureWorks Sales Command Center</h2><div class='factory-caption'>Snowflake-native analytics with Factory AI styling</div></div>", unsafe_allow_html=True)

    with st.spinner("Loading Snowflake data..."):
        sales_df = fetch_dataframe(SALES_BASE_QUERY)
        return_orders_df = fetch_dataframe(RETURN_ORDERS_QUERY)

    if sales_df.empty:
        st.error("No rows returned from DW.fact_internet_sales.")
        st.stop()

    for col in ("sales_amount", "total_product_cost", "order_quantity"):
        sales_df[col] = pd.to_numeric(sales_df[col], errors="coerce").fillna(0.0)
    sales_df["order_date"] = pd.to_datetime(sales_df["order_date"], errors="coerce")
    sales_df = sales_df.dropna(subset=["order_date"]).copy()

    categories = sorted(x for x in sales_df["product_category"].dropna().unique())
    regions = sorted(x for x in sales_df["region"].dropna().unique())
    min_date = sales_df["order_date"].dt.date.min()
    max_date = sales_df["order_date"].dt.date.max()

    st.sidebar.header("Filters")
    selected_dates = st.sidebar.date_input(
        "Date range",
        value=(min_date, max_date),
        min_value=min_date,
        max_value=max_date,
    )
    if isinstance(selected_dates, tuple) and len(selected_dates) == 2:
        start_date, end_date = selected_dates
    else:
        start_date = end_date = selected_dates

    selected_categories = st.sidebar.multiselect(
        "Product categories",
        categories,
        default=categories,
    )
    selected_regions = st.sidebar.multiselect(
        "Regions",
        regions,
        default=regions,
    )

    filtered_df = sales_df[
        (sales_df["order_date"].dt.date >= start_date)
        & (sales_df["order_date"].dt.date <= end_date)
        & (sales_df["product_category"].isin(selected_categories))
        & (sales_df["region"].isin(selected_regions))
    ].copy()

    return_order_ids = set(return_orders_df["sales_order_number"].astype(str).tolist()) if not return_orders_df.empty else set()
    filtered_orders = filtered_df["sales_order_number"].astype(str)
    total_orders = filtered_orders.nunique()
    returned_orders = filtered_orders[filtered_orders.isin(return_order_ids)].nunique()
    return_rate = (returned_orders / total_orders * 100) if total_orders else 0.0

    total_sales = filtered_df["sales_amount"].sum()
    total_profit = (filtered_df["sales_amount"] - filtered_df["total_product_cost"]).sum()

    kpi1, kpi2, kpi3 = st.columns(3)
    kpi1.metric("Total Sales", f"${total_sales:,.2f}")
    kpi2.metric("Total Profit", f"${total_profit:,.2f}")
    kpi3.metric("Return Rate", f"{return_rate:.2f}%")

    trend_df = (
        filtered_df.assign(month=filtered_df["order_date"].dt.to_period("M").dt.to_timestamp())
        .groupby("month", as_index=False)
        .agg(sales_amount=("sales_amount", "sum"), total_product_cost=("total_product_cost", "sum"))
    )
    trend_df["total_profit"] = trend_df["sales_amount"] - trend_df["total_product_cost"]
    trend_plot = trend_df.set_index("month")[["sales_amount", "total_profit"]]

    st.subheader("Sales Trend (Time Series)")
    st.line_chart(trend_plot)

    left, right = st.columns(2)
    top_products = (
        filtered_df.groupby("product_name", as_index=False)["sales_amount"]
        .sum()
        .sort_values("sales_amount", ascending=False)
        .head(10)
        .set_index("product_name")
    )
    left.subheader("Top Products")
    left.bar_chart(top_products)

    geo_df = (
        filtered_df.groupby("country", as_index=False)["sales_amount"]
        .sum()
        .sort_values("sales_amount", ascending=False)
        .set_index("country")
    )
    right.subheader("Sales by Country")
    right.bar_chart(geo_df)

    seg_col, info_col = st.columns([2, 1])
    segment_df = (
        filtered_df.groupby("customer_segment", as_index=False)["sales_amount"]
        .sum()
        .sort_values("sales_amount", ascending=False)
        .set_index("customer_segment")
    )
    seg_col.subheader("Customer Segment Mix")
    seg_col.bar_chart(segment_df)

    info_col.subheader("Active Filter Scope")
    info_col.markdown(
        f"""
        - Rows: **{len(filtered_df):,}**
        - Orders: **{total_orders:,}**
        - Date range: **{start_date} → {end_date}**
        - Categories: **{len(selected_categories)}**
        - Regions: **{len(selected_regions)}**
        """,
    )

    st.subheader("SCD Type 2 History Explorer")
    dim_name = st.selectbox("Dimension", options=list(SCD_DIMENSIONS.keys()))
    dim_cfg = SCD_DIMENSIONS[dim_name]
    scd_df = fetch_scd_history(dim_cfg["table"], dim_cfg["key"], dim_cfg["label"])

    if scd_df.empty:
        st.warning("No SCD rows found for the selected dimension.")
        return

    scd_df["business_key"] = scd_df["business_key"].astype(str)
    scd_df["record_label"] = scd_df["record_label"].fillna(scd_df["business_key"])
    scd_df["_valid_from"] = pd.to_datetime(scd_df["_valid_from"], errors="coerce")
    scd_df["_valid_to"] = pd.to_datetime(scd_df["_valid_to"], errors="coerce")
    scd_df["_is_current"] = scd_df["_is_current"].astype(str).str.lower().isin(["true", "1", "t", "yes"])

    latest_rows = (
        scd_df.sort_values(["business_key", "_valid_from"])
        .groupby("business_key", as_index=False)
        .tail(1)
        .sort_values("business_key")
    )
    option_labels = [f"{row.business_key} — {row.record_label}" for row in latest_rows.itertuples()]
    selected_label = st.selectbox("Business key", options=option_labels)
    selected_key = selected_label.split(" — ", 1)[0]

    history = scd_df[scd_df["business_key"] == selected_key].sort_values("_valid_from").reset_index(drop=True)
    history["version"] = [f"v{i+1}" for i in range(len(history))]
    st.dataframe(history, use_container_width=True)


def main() -> None:
    try:
        render_dashboard()
    except Exception as exc:
        st.error(f"Dashboard failed to load: {exc}")
        st.exception(exc)


if __name__ == "__main__":
    main()
