# Cloud Data Pipeline for Housing Analytics

[![CI](https://github.com/adelrioj01/End-to-End-Cloud-Data-Pipeline-for-Housing-Availability-Analytics/actions/workflows/ci.yml/badge.svg)](https://github.com/adelrioj01/End-to-End-Cloud-Data-Pipeline-for-Housing-Availability-Analytics/actions/workflows/ci.yml)

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

## Looker Studio Dashboard

The analytics layer is consumed by an interactive Looker Studio report
designed for housing managers, accommodation teams, and admissions staff.

[Open the Housing Availability & Student Assignment Dashboard](https://datastudio.google.com/reporting/54160dd3-88a8-464e-9533-bbdc40896954)

The report turns the BigQuery marts into three complementary views:

### Executive Overview

Provides an at-a-glance view of the current housing situation:

- total rooms and beds
- assigned students and available beds
- overall occupancy rate
- occupied versus available capacity by building
- comparison of building occupancy rates

### Building Capacity

Supports capacity planning and identification of buildings that are close
to full occupancy or still have significant availability:

- available beds by building
- total rooms and bed capacity
- rooms with kitchens and private bathrooms
- occupancy thresholds and detailed building-level metrics

### Student Assignments

Provides an operational view of student placements:

- assigned students by building
- daily assignment activity
- student, building, room, and assignment-date details
- housing amenities and requested student preferences

The dashboard reads only from curated models in the `housing_analytics`
dataset. Its primary sources are:

- `fct_building_availability`
- `fct_student_assignments`
- `fct_assignments_daily`

The current demonstration dataset contains 150 students, 120 assignments,
6 buildings, 72 rooms, and 180 beds. This produces an overall occupancy rate
of 66.67%, with 60 beds available for new assignments.

The report enables users to identify capacity constraints, compare buildings,
locate available beds, review individual placements, and monitor assignment
activity without querying BigQuery directly.

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

Terraform is the source of truth for resource names. The default dataset IDs
are stable and can be overridden explicitly in `terraform.tfvars`:

- `housing_raw` as the raw BigQuery dataset
- `housing_analytics` as the analytics BigQuery dataset
- `<project_id>-housing-raw` as the raw Cloud Storage bucket

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

### Airflow with Docker

Docker Desktop with the WSL2 backend is the recommended way to run
Airflow locally on Windows. Before starting it:

1. Start Docker Desktop and wait until it shows `Engine running`.
2. Authenticate locally with Google Cloud Application Default Credentials:

   ```powershell
   gcloud auth application-default login
   gcloud config set project YOUR_PROJECT_ID
   ```

3. Copy `.env.example` to `.env` and replace all example values. On
   Windows, set `GOOGLE_APPLICATION_CREDENTIALS_HOST` to the ADC JSON
   file using forward slashes. The credential is mounted read-only into
   the containers and is never copied into the Docker image.

Build and start PostgreSQL, the Airflow webserver, and the scheduler:

```powershell
docker compose build
docker compose up -d
```

Open [http://localhost:8080](http://localhost:8080) and sign in with
username `airflow` and the value of `AIRFLOW_ADMIN_PASSWORD` from
`.env`. The DAG is named `housing_analytics_pipeline`.

Useful commands:

```powershell
# Check container health
docker compose ps

# Check that the DAG imports correctly
docker compose exec airflow-scheduler airflow dags list-import-errors

# Trigger the complete pipeline from the terminal
docker compose exec airflow-scheduler `
  airflow dags trigger housing_analytics_pipeline

# Follow scheduler logs
docker compose logs -f airflow-scheduler

# Stop containers without deleting their data
docker compose stop

# Start the existing containers again
docker compose start

# Remove containers while preserving named volumes
docker compose down
```

The pipeline uploads the four CSV files to Cloud Storage, replaces the
four raw BigQuery tables, compiles and runs the ten dbt models, and
executes all data quality tests. Do not expose port `8080` publicly;
this Compose setup is intended for local development.

### Data quality rules

In addition to schema, uniqueness, and relationship checks, `dbt test`
validates these business rules:

- each student has at most one current assignment
- room occupancy never exceeds capacity
- available beds never become negative
- every room has a positive capacity
- assigned rooms and buildings satisfy all requested student preferences

Assignment rows are currently treated as active because the source does
not yet contain an end date or assignment status.
