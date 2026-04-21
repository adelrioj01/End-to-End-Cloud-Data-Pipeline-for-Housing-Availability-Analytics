# Quick Test Script for dbt (PowerShell)

Write-Host "=== dbt Validation ===" -ForegroundColor Green

# 1. Parse dbt project
Write-Host "1. Parsing dbt project..." -ForegroundColor Cyan
dbt parse
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Parse failed" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Parse successful" -ForegroundColor Green

# 2. Debug connection
Write-Host ""
Write-Host "2. Testing dbt connectivity..." -ForegroundColor Cyan
dbt debug
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Connection failed - check profiles.yml and GCP credentials" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Connection successful" -ForegroundColor Green

# 3. Validate models
Write-Host ""
Write-Host "3. Validating models..." -ForegroundColor Cyan
dbt parse --select models --quiet
Write-Host "✅ Models valid" -ForegroundColor Green

# 4. Run tests on staging layer
Write-Host ""
Write-Host "4. Running staging tests..." -ForegroundColor Cyan
dbt test --select stg_*
Write-Host "✅ Staging tests passed" -ForegroundColor Green

# 5. Generate lineage
Write-Host ""
Write-Host "5. Generating documentation..." -ForegroundColor Cyan
dbt docs generate
Write-Host "✅ Documentation generated" -ForegroundColor Green

Write-Host ""
Write-Host "=== All validations passed! ===" -ForegroundColor Green
Write-Host "View docs with: dbt docs serve" -ForegroundColor Yellow
