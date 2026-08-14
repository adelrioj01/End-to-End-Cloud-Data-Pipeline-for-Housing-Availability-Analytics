# Portfolio evidence checklist

Add the four screenshots below to this directory. Crop browser chrome and any
personal information, but keep enough context to identify the service and
project. Do not include credentials, billing IDs, email addresses, or local
filesystem paths.

| File | Capture | What must be visible |
|---|---|---|
| `airflow-dag-success.png` | Airflow Grid or Graph view | `housing_analytics_pipeline`, one complete run, and all 13 tasks in green |
| `bigquery-tables.png` | BigQuery Explorer | Project `housing-analytics-dev`, datasets `housing_raw` and `housing_analytics`, and their table/model names |
| `dbt-tests.png` | Airflow task log or terminal | Final dbt test summary showing all 61 tests passing and zero failures |
| `looker-dashboard.png` | Published Looker Studio report | Dashboard title, main KPIs, and at least one capacity or occupancy chart |

Recommended image format is PNG, approximately 1600 px wide. After adding the
files, insert them in the README under **Project evidence**, with a short
caption explaining what each image proves.

The architecture diagram already stored here as `architecture.svg` is generated
from the implemented components and should remain version controlled.
