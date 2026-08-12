FROM apache/airflow:2.8.0-python3.11

RUN pip install --no-cache-dir \
    apache-airflow-providers-google==10.12.0 \
    dbt-bigquery==1.7.0 \
    python-dotenv==1.0.0
