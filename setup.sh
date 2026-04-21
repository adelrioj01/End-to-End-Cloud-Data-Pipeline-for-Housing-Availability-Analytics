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

# 2. Set up Python virtual environment
echo "Setting up Python environment..."
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# 3. Install dependencies
echo "Installing dependencies..."
pip install -r requirements.txt

# 4. Setup dbt profiles directory
echo "Setting up dbt profiles..."
mkdir -p ~/.dbt
cp profiles.yml ~/.dbt/profiles.yml

# 5. Initialize Airflow
echo "Initializing Airflow database..."
export AIRFLOW_HOME=~/airflow
airflow db init

# 6. Create Airflow admin user
echo "Creating Airflow admin user..."
airflow users create \
    --username admin \
    --password admin \
    --firstname Admin \
    --lastname User \
    --role Admin \
    --email admin@example.com || echo "User may already exist"

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
echo "2. Run: terraform plan && terraform apply"
echo "3. Upload raw data to GCS"
echo "4. Run: airflow standalone"
echo "5. Access Airflow at http://localhost:8080"
