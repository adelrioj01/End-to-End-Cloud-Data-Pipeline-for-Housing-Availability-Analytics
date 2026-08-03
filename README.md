# Cloud Data Pipeline for Housing Analytics

## Problem
A housing management system needs to understand room availability,
student preferences, and current assignments in order to optimize
housing allocation and improve occupancy planning.

The raw operational data is fragmented and not analytics-ready,
making it difficult to answer questions such as:
- How many beds are available per building?
- Which rooms match student preferences?
- What is the current occupancy rate?

## Solution
This project implements an end-to-end batch data pipeline in the cloud
that ingests housing data, applies business rules, and produces
analytics-ready tables for reporting and decision making.

The pipeline is fully automated, reproducible, and designed using
modern data engineering best practices.

## Tech Stack
- Google Cloud Platform (GCP)
  - Cloud Storage (data lake)
  - BigQuery (data warehouse)
- Terraform (Infrastructure as Code)
- Apache Airflow (workflow orchestration)
- dbt (data transformations)
- Python & SQL

## Architecture
The pipeline follows a batch-oriented architecture:

1. Raw data is ingested and stored in Cloud Storage
2. Raw tables are loaded into BigQuery
3. Data is transformed using dbt into staging, fact, and mart layers
4. Final analytics tables are generated for consumption
5. The entire workflow is orchestrated using Airflow

## Data Model
The core entities of the domain are:
- Students
- Buildings
- Rooms
- Assignments

These entities are modeled to enforce business constraints such as
room capacity, student preferences, and unique assignments.

## Business Logic
The pipeline applies the following business rules:
- A student can only be assigned to one room at a time
- Room capacity cannot be exceeded
- Student preferences (A/C, kitchen, dining, private bathroom)
  must be satisfied by the assigned room
- Availability metrics are computed per room and building

## Data Warehouse Design
BigQuery tables are optimized for analytics:
- Tables are partitioned by date to support time-based queries
- Tables are clustered by building_id and student_id
  to optimize filtering and joins

These optimizations reduce query cost and improve performance
for common analytical workloads.

## Outputs
The pipeline produces the following analytics-ready tables:
- Daily available beds per building
- Current student-to-room assignments
- Rooms compatible with student preferences
- Occupancy and utilization metrics

## Dashboard
A lightweight dashboard is built on top of BigQuery to visualize:
- Available beds over time
- Occupancy rate per building

(Screenshots available in the /dashboard folder)

## Reproducibility
The entire project is fully reproducible.

### Infrastructure
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your real values
terraform init
terraform apply
```

Terraform is the source of truth for resource names. With the default
`environment = "dev"`, it creates:

- `housing_raw_dev` as the raw BigQuery dataset
- `housing_analytics_dev` as the analytics BigQuery dataset
- `<project_id>-housing-raw-dev` as the raw Cloud Storage bucket

Copy `.env.example` to `.env` and set `GCP_PROJECT_ID` to the same
`project_id` used by Terraform. The `BQ_DATASET_RAW`,
`BQ_DATASET_ANALYTICS`, `BQ_LOCATION`, and `GCS_BUCKET_RAW` values must
match the Terraform outputs. Both Airflow and dbt read these values from
the environment; no GCP project ID is hard-coded in the dbt project.

After applying Terraform, verify the effective names with:

```bash
terraform output
```

### Local Python environment

Use Python 3.11.9 for the pinned Airflow 2.8 and dbt 1.7 versions.
Airflow and dbt are installed in two phases because dbt 1.7 requires
`pathspec < 0.12`, while the Airflow constraints pin a newer version
during Airflow installation:

```powershell
conda create --prefix .venv python=3.11.9 pip terraform=1.9.8 -y
conda activate .\.venv
python -m pip install -r requirements-airflow.txt `
  --constraint https://raw.githubusercontent.com/apache/airflow/constraints-2.8.0/constraints-3.11.txt
python -m pip install -r requirements-dbt.txt
python -m pip check
```

Airflow should be run in WSL2 or Docker for normal development and
deployment; the native Windows environment is suitable for static DAG
validation and dbt development.
