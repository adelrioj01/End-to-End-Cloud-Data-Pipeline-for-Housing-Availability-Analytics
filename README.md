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
terraform init
terraform apply
