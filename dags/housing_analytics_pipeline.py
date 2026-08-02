import os
from datetime import datetime, timedelta
from pathlib import Path
from airflow import DAG
from airflow.models import Variable
from airflow.providers.google.cloud.transfers.local_to_gcs import LocalFilesystemToGCSOperator
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator
from airflow.providers.standard.operators.bash import BashOperator
from airflow.utils.dates import days_ago

# Get configuration from environment variables or Airflow variables
GCP_PROJECT_ID = os.getenv('GCP_PROJECT_ID') or Variable.get('GCP_PROJECT_ID', default='')
GCS_BUCKET_RAW = os.getenv('GCS_BUCKET_RAW') or Variable.get('GCS_BUCKET_RAW', default='')
BQ_DATASET_RAW = os.getenv('BQ_DATASET_RAW') or Variable.get('BQ_DATASET_RAW', default='housing_raw_dev')
BQ_DATASET_ANALYTICS = os.getenv('BQ_DATASET_ANALYTICS') or Variable.get('BQ_DATASET_ANALYTICS', default='housing_analytics_dev')
BQ_LOCATION = os.getenv('BQ_LOCATION') or Variable.get('BQ_LOCATION', default='US')

DBT_ENV = {
    'GCP_PROJECT_ID': GCP_PROJECT_ID,
    'BQ_DATASET_RAW': BQ_DATASET_RAW,
    'BQ_DATASET_ANALYTICS': BQ_DATASET_ANALYTICS,
    'BQ_LOCATION': BQ_LOCATION,
}

# Project directory - get parent of dags folder
PROJECT_DIR = str(Path(__file__).parent.parent)

default_args = {
    'owner': 'housing_team',
    'depends_on_past': False,
    'start_date': days_ago(1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'housing_analytics_pipeline',
    default_args=default_args,
    description='End-to-end housing analytics pipeline',
    schedule='@daily',
    catchup=False,
    tags=['housing', 'analytics'],
)

# Task 1: Upload raw data to GCS
upload_assignments = LocalFilesystemToGCSOperator(
    task_id='upload_assignments_to_gcs',
    src=str(Path(PROJECT_DIR) / 'Data' / 'raw_assignments.csv'),
    dst='raw_data/raw_assignments.csv',
    bucket=GCS_BUCKET_RAW,
    gcp_conn_id='google_cloud_default',
    dag=dag,
)

upload_buildings = LocalFilesystemToGCSOperator(
    task_id='upload_buildings_to_gcs',
    src=str(Path(PROJECT_DIR) / 'Data' / 'raw_buildings.csv'),
    dst='raw_data/raw_buildings.csv',
    bucket=GCS_BUCKET_RAW,
    gcp_conn_id='google_cloud_default',
    dag=dag,
)

upload_rooms = LocalFilesystemToGCSOperator(
    task_id='upload_rooms_to_gcs',
    src=str(Path(PROJECT_DIR) / 'Data' / 'raw_rooms.csv'),
    dst='raw_data/raw_rooms.csv',
    bucket=GCS_BUCKET_RAW,
    gcp_conn_id='google_cloud_default',
    dag=dag,
)

upload_students = LocalFilesystemToGCSOperator(
    task_id='upload_students_to_gcs',
    src=str(Path(PROJECT_DIR) / 'Data' / 'raw_students.csv'),
    dst='raw_data/raw_students.csv',
    bucket=GCS_BUCKET_RAW,
    gcp_conn_id='google_cloud_default',
    dag=dag,
)

# Task 2: Load data from GCS to BigQuery
load_assignments_to_bq = GCSToBigQueryOperator(
    task_id='load_assignments_to_bigquery',
    bucket=GCS_BUCKET_RAW,
    source_objects=['raw_data/raw_assignments.csv'],
    destination_project_dataset_table=f'{GCP_PROJECT_ID}.{BQ_DATASET_RAW}.raw_assignments',
    schema_fields=[
        {'name': 'student_id', 'type': 'INTEGER'},
        {'name': 'building_id', 'type': 'INTEGER'},
        {'name': 'room_number', 'type': 'INTEGER'},
        {'name': 'assigned_at', 'type': 'TIMESTAMP'},
        {'name': '_ingested_at', 'type': 'TIMESTAMP'},
    ],
    write_disposition='WRITE_TRUNCATE',
    gcp_conn_id='google_cloud_default',
    dag=dag,
)

load_buildings_to_bq = GCSToBigQueryOperator(
    task_id='load_buildings_to_bigquery',
    bucket=GCS_BUCKET_RAW,
    source_objects=['raw_data/raw_buildings.csv'],
    destination_project_dataset_table=f'{GCP_PROJECT_ID}.{BQ_DATASET_RAW}.raw_buildings',
    schema_fields=[
        {'name': 'building_id', 'type': 'INTEGER'},
        {'name': 'name', 'type': 'STRING'},
        {'name': 'address', 'type': 'STRING'},
        {'name': 'has_ac', 'type': 'BOOLEAN'},
        {'name': 'has_dining', 'type': 'BOOLEAN'},
        {'name': '_ingested_at', 'type': 'TIMESTAMP'},
    ],
    write_disposition='WRITE_TRUNCATE',
    gcp_conn_id='google_cloud_default',
    dag=dag,
)

load_rooms_to_bq = GCSToBigQueryOperator(
    task_id='load_rooms_to_bigquery',
    bucket=GCS_BUCKET_RAW,
    source_objects=['raw_data/raw_rooms.csv'],
    destination_project_dataset_table=f'{GCP_PROJECT_ID}.{BQ_DATASET_RAW}.raw_rooms',
    schema_fields=[
        {'name': 'building_id', 'type': 'INTEGER'},
        {'name': 'room_number', 'type': 'INTEGER'},
        {'name': 'num_beds', 'type': 'INTEGER'},
        {'name': 'private_bathrooms', 'type': 'BOOLEAN'},
        {'name': 'has_kitchen', 'type': 'BOOLEAN'},
        {'name': '_ingested_at', 'type': 'TIMESTAMP'},
    ],
    write_disposition='WRITE_TRUNCATE',
    gcp_conn_id='google_cloud_default',
    dag=dag,
)

load_students_to_bq = GCSToBigQueryOperator(
    task_id='load_students_to_bigquery',
    bucket=GCS_BUCKET_RAW,
    source_objects=['raw_data/raw_students.csv'],
    destination_project_dataset_table=f'{GCP_PROJECT_ID}.{BQ_DATASET_RAW}.raw_students',
    schema_fields=[
        {'name': 'student_id', 'type': 'INTEGER'},
        {'name': 'name', 'type': 'STRING'},
        {'name': 'wants_ac', 'type': 'BOOLEAN'},
        {'name': 'wants_dining', 'type': 'BOOLEAN'},
        {'name': 'wants_kitchen', 'type': 'BOOLEAN'},
        {'name': 'wants_private_bathroom', 'type': 'BOOLEAN'},
        {'name': '_ingested_at', 'type': 'TIMESTAMP'},
    ],
    write_disposition='WRITE_TRUNCATE',
    gcp_conn_id='google_cloud_default',
    dag=dag,
)

# Task 3: dbt transformations (compile, run, test)
dbt_compile = BashOperator(
    task_id='dbt_compile',
    bash_command=f'cd {PROJECT_DIR} && dbt compile --profiles-dir ~/.dbt',
    env=DBT_ENV,
    append_env=True,
    dag=dag,
)

dbt_run = BashOperator(
    task_id='dbt_run',
    bash_command=f'cd {PROJECT_DIR} && dbt run --profiles-dir ~/.dbt',
    env=DBT_ENV,
    append_env=True,
    dag=dag,
)

dbt_test = BashOperator(
    task_id='dbt_test',
    bash_command=f'cd {PROJECT_DIR} && dbt test --profiles-dir ~/.dbt --fail-fast',
    env=DBT_ENV,
    append_env=True,
    dag=dag,
)

# Set dependencies
[upload_assignments, upload_buildings, upload_rooms, upload_students] >> [load_assignments_to_bq, load_buildings_to_bq, load_rooms_to_bq, load_students_to_bq] >> dbt_compile >> dbt_run >> dbt_test
