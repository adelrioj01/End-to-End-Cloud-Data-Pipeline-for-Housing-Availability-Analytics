#!/bin/bash

# Setup script for Housing Analytics Pipeline

echo "=== Housing Analytics Pipeline Setup ==="

# 1. Create .env file from .env.example
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cp .env.example .env
    echo "⚠️  Please edit .env with your GCP project details"
    exit 1
fi

# Load environment variables
source .env
: "${AIRFLOW_ADMIN_PASSWORD:?Set AIRFLOW_ADMIN_PASSWORD in .env}"
: "${AIRFLOW_WEBSERVER_SECRET_KEY:?Set AIRFLOW_WEBSERVER_SECRET_KEY in .env}"

# 2. Set up Python virtual environment
echo "Setting up Python environment..."
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# 3. Install dependencies
echo "Installing dependencies..."
pip install -r requirements-airflow.txt \
    --constraint https://raw.githubusercontent.com/apache/airflow/constraints-2.8.0/constraints-3.11.txt
pip install -r requirements-dbt.txt
pip check

# 4. Setup dbt profiles directory
echo "Setting up dbt profiles..."
mkdir -p ~/.dbt
cp profiles.yml ~/.dbt/profiles.yml

# 5. Initialize Airflow
echo "Initializing Airflow database..."
export AIRFLOW_HOME=~/airflow
export AIRFLOW__WEBSERVER__SECRET_KEY="$AIRFLOW_WEBSERVER_SECRET_KEY"
airflow db migrate

# 6. Create Airflow admin user
echo "Creating Airflow admin user..."
airflow users delete --username airflow 2>/dev/null || true
airflow users create \
    --username airflow \
    --password "$AIRFLOW_ADMIN_PASSWORD" \
    --firstname Airflow \
    --lastname Admin \
    --role Admin \
    --email airflow@example.com

# 7. Initialize Terraform
echo "Initializing Terraform..."
cd terraform
terraform init
cd ..

# 8. Test dbt connectivity
echo "Testing dbt connectivity..."
dbt debug

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Update terraform/terraform.tfvars with your GCP project ID"
echo "2. Run terraform plan, review it, and only then run terraform apply"
echo "3. Upload raw data to GCS"
echo "4. Run: airflow standalone"
echo "5. Access Airflow at http://localhost:8080"
