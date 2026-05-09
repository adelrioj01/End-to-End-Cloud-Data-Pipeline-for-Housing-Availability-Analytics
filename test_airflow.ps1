# Quick Test Script for Airflow DAG

Write-Host "=== Airflow DAG Validation ===" -ForegroundColor Green

# 1. Set Airflow home
$env:AIRFLOW_HOME = "$env:USERPROFILE\airflow"

# 2. Check DAG syntax
Write-Host "1. Checking DAG syntax..." -ForegroundColor Cyan
python -m py_compile dags/housing_analytics_pipeline.py
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Syntax error in DAG" -ForegroundColor Red
    exit 1
}
Write-Host "✅ DAG syntax valid" -ForegroundColor Green

# 3. List DAGs
Write-Host ""
Write-Host "2. Listing available DAGs..." -ForegroundColor Cyan
airflow dags list

# 4. List tasks in DAG
Write-Host ""
Write-Host "3. Listing tasks in pipeline..." -ForegroundColor Cyan
airflow tasks list housing_analytics_pipeline

# 5. Validate DAG structure
Write-Host ""
Write-Host "4. Validating DAG structure..." -ForegroundColor Cyan
airflow dags test housing_analytics_pipeline

Write-Host ""
Write-Host "=== DAG validation complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Verify GCP credentials are configured"
Write-Host "2. Set connection in Airflow UI: Admin > Connections > google_cloud_default"
Write-Host "3. Run: airflow standalone"
Write-Host "4. Access at: http://localhost:8080"
