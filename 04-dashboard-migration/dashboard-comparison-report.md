# Dashboard Comparison Report: Repoint vs Rebuild

## Goal

Compare two migration options for the AdventureWorks sales dashboard:

1. **Repoint** existing Power BI artifacts from SQL Server/CSV to Snowflake.
2. **Rebuild** the dashboard as a Snowflake-native Streamlit app.

This report summarizes effort, feature parity, maintenance implications, Snowflake-native benefits, and a recommendation for a typical implementation-partner customer profile.

---

## Option Summary

- **Repoint (Power BI → Snowflake):** Faster path to production with lower delivery risk and strong continuity for business users already invested in Power BI.
- **Rebuild (Streamlit on Snowflake):** Higher initial implementation effort, but better long-term flexibility for Snowflake-native workflows, custom UX, and integrated data-app patterns.

---

## Effort Comparison

Assumptions:
- Existing `.pbix` model and report pages are usable.
- Snowflake `DW` objects are already available.
- Team has baseline skills in both BI modeling and Python.

| Dimension | Repoint Existing Power BI | Rebuild in Streamlit |
|---|---|---|
| Initial implementation effort | **Low–Medium** | **Medium–High** |
| Estimated delivery window | **2–5 days** | **1–3 weeks** |
| Data model transition work | Update connector + query rewrites + measure validation | Re-implement query layer, metric logic, and all visuals |
| UX migration effort | Low (existing report UX retained) | High (design and interaction patterns rebuilt) |
| Testing effort | Medium (refresh + parity checks) | Medium–High (functional + visual + interaction validation) |
| Change-management impact | Low (minimal user retraining) | Medium–High (new UI/tool adoption) |

---

## Feature Parity (Power BI vs Streamlit)

| Power BI Feature / Capability | Current Power BI State | Streamlit Equivalent in `streamlit_app.py` | Parity Status | Notes |
|---|---|---|---|---|
| Sales KPIs | Sales/Budget/Variance style metrics | KPI cards for total sales, total profit, return rate | **Partial** | Budget variance visual is not currently explicit in Streamlit app |
| Time-series trend analysis | Sales trend over time | Plotly line chart for monthly sales/profit trend | **Full** | Comparable analytic intent |
| Product performance analysis | Product-focused views and slicers | Top products horizontal bar chart + category filter | **Full** | Equivalent for core product ranking use case |
| Customer insights/segmentation | Customer details page and demographics | Customer segment pie chart + filterable scope | **Partial** | High-level segmentation present; detailed customer drill pages are lighter |
| Geographic analysis | Territory/location visuals | Country-based choropleth sales map | **Partial** | Geographic view exists; advanced map interactions differ from Power BI |
| Interactive filtering | Slicers across pages | Sidebar filters: date range, product category, region | **Full** | Core interaction behavior is equivalent |
| Multi-page report navigation | Multiple report pages | Single-page app sections | **Partial** | Content present, but page paradigm differs |
| SCD Type 2 history exploration | Not native in original report | Dedicated SCD Type 2 timeline explorer | **Enhanced (Streamlit advantage)** | New capability beyond original dashboard |

---

## Maintenance Considerations

## Repoint Path (Power BI retained)

- **Pros**
  - Lowest operational disruption for analysts and business stakeholders.
  - Existing report governance (workspace, refresh, RLS patterns) can remain largely unchanged.
  - Smaller engineering burden if BI team already owns Power BI lifecycle.
- **Cons**
  - Continued dependency on Power BI licensing/admin model.
  - Connector and DirectQuery/Import tuning still required for Snowflake cost/performance balance.
  - Advanced application-like workflows remain harder than in code-first frameworks.

## Rebuild Path (Streamlit)

- **Pros**
  - Code-first lifecycle enables PR-based versioning, CI validation, and reproducible deployments.
  - Easier integration of custom workflows (write-backs, guided diagnostics, operational tools).
  - Native control of UI/logic without vendor visualization constraints.
- **Cons**
  - Requires Python + data-app engineering skills for ongoing ownership.
  - More custom responsibility for governance patterns (authz integration, observability, QA rigor).
  - Higher ongoing ownership overhead if team is BI-only and not app-engineering capable.

---

## Snowflake-Native Advantages of Streamlit

1. **Direct alignment with Snowflake platform workflows**  
   Single stack for storage, transformation, and app query patterns reduces context switching.

2. **Data app extensibility**  
   Streamlit can evolve from read-only dashboard to interactive operational app (scenario analysis, exception triage, SCD record audits).

3. **Code-centric delivery model**  
   Git-native change control, peer review, and environment promotion are straightforward.

4. **Custom SCD Type 2 observability**  
   The implemented timeline explorer surfaces historical validity windows in ways traditional BI reports typically do not.

5. **Styling and experience control**  
   Factory AI visual identity (dark base, warm orange accent) is fully customizable and repeatable.

---

## Recommendation (Partner Typical Customer Profile)

### Typical customer profile assumed

- Mid-market to enterprise customer with an existing Power BI footprint.
- Small-to-medium data team (strong BI analysts, limited full-stack app engineering).
- Priority on near-term dashboard continuity while migrating warehouse workloads to Snowflake.

### Recommended approach

**Primary recommendation: staged strategy — repoint first, then selectively rebuild high-value experiences in Streamlit.**

Rationale:
- Repointing delivers fastest time-to-value and lowest adoption risk.
- Streamlit rebuild should be targeted where Snowflake-native or workflow-driven capabilities materially outperform Power BI (for example, SCD history diagnostics, custom decision support, or deeply branded partner-facing portals).
- This sequence balances delivery speed, business continuity, and long-term modernization potential.

---

## Decision Guidance

- Choose **Repoint-first** when timeline, parity, and user adoption risk are dominant.
- Choose **Rebuild-first** when productized analytics, custom workflows, and code-native operations are strategic requirements from day one.
