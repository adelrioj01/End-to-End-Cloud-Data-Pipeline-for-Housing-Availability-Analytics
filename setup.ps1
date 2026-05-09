# Setup script for Housing Analytics Pipeline (Windows PowerShell)

Write-Host "=== Housing Analytics Pipeline Setup ===" -ForegroundColor Green

# 1. Create .env file from .env.example
if (-not (Test-Path ".env")) {
    Write-Host "Creating .env file..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host "⚠️  Please edit .env with your GCP project details" -ForegroundColor Red
    exit
}

Write-Host "Loading environment variables..." -ForegroundColor Yellow

# 2. Install dependencies
Write-Host "Installing dependencies..." -ForegroundColor Yellow
pip install -r requirements.txt

# 3. Setup dbt profiles directory
Write-Host "Setting up dbt profiles..." -ForegroundColor Yellow
$dbhome = "$env:USERPROFILE\.dbt"
if (-not (Test-Path $dbhome)) {
    New-Item -ItemType Directory -Path $dbthome -Force | Out-Null
}
Copy-Item "profiles.yml" "$dbhome\profiles.yml" -Force

# 4. Initialize Airflow
Write-Host "Initializing Airflow database..." -ForegroundColor Yellow
$env:AIRFLOW_HOME = "$env:USERPROFILE\airflow"
airflow db init

# 5. Create Airflow admin user
Write-Host "Creating Airflow admin user..." -ForegroundColor Yellow
airflow users create `
    --username admin `
    --password admin `
    --firstname Admin `
    --lastname User `
    --role Admin `
    --email admin@example.com

# 6. Initialize Terraform
Write-Host "Initializing Terraform..." -ForegroundColor Yellow
Push-Location terraform
terraform init
Pop-Location

# 7. Test dbt connectivity
Write-Host "Testing dbt connectivity..." -ForegroundColor Yellow
dbt debug

Write-Host ""
Write-Host "✅ Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Update terraform/terraform.tfvars with your GCP project ID"
Write-Host "2. Run: terraform plan && terraform apply"
Write-Host "3. Upload raw data to GCS"
Write-Host "4. Run: airflow standalone"
Write-Host "5. Access Airflow at http://localhost:8080"
