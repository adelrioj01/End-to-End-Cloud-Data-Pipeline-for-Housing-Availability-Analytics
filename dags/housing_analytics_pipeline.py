from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.google.cloud.transfers.local_to_gcs import LocalFilesystemToGCSOperator
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator
from airflow.providers.standard.operators.bash import BashOperator
from airflow.utils.dates import days_ago

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
    src='Data/raw_assignments.csv',
    dst='raw_data/raw_assignments.csv',
    bucket='housing-analytics-dev-housing-raw',
    gcp_conn_id='google_cloud_default',
    dag=dag,
)

upload_buildings = LocalFilesystemToGCSOperator(
    task_id='upload_buildings_to_gcs',
    src='Data/raw_buildings.csv',
    dst='raw_data/raw_buildings.csv',
    bucket='housing-analytics-dev-housing-raw',
    gcp_conn_id='google_cloud_default',
    dag=dag,
)

upload_rooms = LocalFilesystemToGCSOperator(
    task_id='upload_rooms_to_gcs',
    src='Data/raw_rooms.csv',
    dst='raw_data/raw_rooms.csv',
    bucket='housing-analytics-dev-housing-raw',
    gcp_conn_id='google_cloud_default',
    dag=dag,
)

upload_students = LocalFilesystemToGCSOperator(
    task_id='upload_students_to_gcs',
    src='Data/raw_students.csv',
    dst='raw_data/raw_students.csv',
    bucket='housing-analytics-dev-housing-raw',
    gcp_conn_id='google_cloud_default',
    dag=dag,
)

# Task 2: Load data from GCS to BigQuery
load_assignments_to_bq = GCSToBigQueryOperator(
    task_id='load_assignments_to_bigquery',
    bucket='housing-analytics-dev-housing-raw',
    source_objects=['raw_data/raw_assignments.csv'],
    destination_project_dataset_table='housing-analytics-dev.housing_raw.raw_assignments',
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
    bucket='housing-analytics-dev-housing-raw',
    source_objects=['raw_data/raw_buildings.csv'],
    destination_project_dataset_table='housing-analytics-dev.housing_raw.raw_buildings',
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
    bucket='housing-analytics-dev-housing-raw',
    source_objects=['raw_data/raw_rooms.csv'],
    destination_project_dataset_table='housing-analytics-dev.housing_raw.raw_rooms',
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
    bucket='housing-analytics-dev-housing-raw',
    source_objects=['raw_data/raw_students.csv'],
    destination_project_dataset_table='housing-analytics-dev.housing_raw.raw_students',
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

# Task 3: Run dbt transformations
run_dbt = BashOperator(
    task_id='run_dbt_models',
    bash_command='cd /path/to/project/End-to-End-Cloud-Data-Pipeline-for-Housing-Availability-Analytics && dbt run',
    dag=dag,
)

# Set dependencies
[upload_assignments, upload_buildings, upload_rooms, upload_students] >> [load_assignments_to_bq, load_buildings_to_bq, load_rooms_to_bq, load_students_to_bq] >> run_dbt
