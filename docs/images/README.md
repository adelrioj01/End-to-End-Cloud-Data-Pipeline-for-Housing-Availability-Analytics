# Portfolio evidence checklist

This directory contains the portfolio screenshots used in the main README.
They retain enough context to identify the service and project while excluding
credentials, billing IDs, email addresses, and local secret values.

| File | Capture | What must be visible |
|---|---|---|
| `airflow-dag-success.png` | Airflow Grid or Graph view | `housing_analytics_pipeline`, one complete run, and all 13 tasks in green |
| `bigquery-raw-tables.png` | BigQuery Explorer | The four source-aligned tables in `housing_raw` |
| `bigquery-analytics-models.png` | BigQuery Explorer | Project `housing-analytics-dev` and all ten dbt models in `housing_analytics` |
| `dbt-tests.png` | Airflow task log or terminal | Final dbt test summary showing all 61 tests passing and zero failures |
| `looker-dashboard.png` | Published Looker Studio report | Dashboard title, main KPIs, and at least one capacity or occupancy chart |

PNG screenshots are embedded in the README under **Project evidence**, with a
short caption explaining what each image proves.

The architecture diagram already stored here as `architecture.svg` is generated
from the implemented components and should remain version controlled.
