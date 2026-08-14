#requires -Version 5.1

# Setup script for Housing Analytics Pipeline (Windows PowerShell)

$ErrorActionPreference = "Stop"

Write-Host "=== Housing Analytics Pipeline Setup ===" -ForegroundColor Green

# Determine the project directory from the location of this script
$ProjectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectDir

# Load variables from a .env file into the current process
function Import-DotEnv {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    Get-Content $Path | ForEach-Object {
        $line = $_.Trim()

        if (
            -not [string]::IsNullOrWhiteSpace($line) -and
            -not $line.StartsWith("#") -and
            $line.Contains("=")
        ) {
            $parts = $line -split "=", 2
            $name = $parts[0].Trim()
            $value = $parts[1].Trim()

            # Remove matching surrounding quotation marks
            if (
                $value.Length -ge 2 -and
                (
                    ($value.StartsWith('"') -and $value.EndsWith('"')) -or
                    ($value.StartsWith("'") -and $value.EndsWith("'"))
                )
            ) {
                $value = $value.Substring(1, $value.Length - 2)
            }

            [Environment]::SetEnvironmentVariable(
                $name,
                $value,
                [EnvironmentVariableTarget]::Process
            )
        }
    }
}

# 1. Create .env file from .env.example when necessary
$envFile = Join-Path $ProjectDir ".env"
$envExampleFile = Join-Path $ProjectDir ".env.example"

if (-not (Test-Path $envFile)) {
    if (-not (Test-Path $envExampleFile)) {
        throw "Neither .env nor .env.example was found in $ProjectDir."
    }

    Write-Host "Creating .env file from .env.example..." -ForegroundColor Yellow
    Copy-Item $envExampleFile $envFile

    Write-Host ""
    Write-Host "The .env file was created." -ForegroundColor Yellow
    Write-Host "Add your GCP configuration to it, then run this script again." -ForegroundColor Red
    Write-Host ""
    Write-Host "Required values:" -ForegroundColor Cyan
    Write-Host "GCP_PROJECT_ID=your-gcp-project-id"
    Write-Host "GCS_BUCKET_RAW=your-raw-data-bucket"
    Write-Host "BQ_DATASET_RAW=housing_raw"
    Write-Host "BQ_DATASET_ANALYTICS=housing_analytics"
    Write-Host "GOOGLE_APPLICATION_CREDENTIALS_HOST=C:\path\to\application_default_credentials.json"
    Write-Host "AIRFLOW_ADMIN_PASSWORD=replace-with-a-local-password"
    Write-Host "AIRFLOW_WEBSERVER_SECRET_KEY=replace-with-a-long-random-local-value"

    exit 1
}

Write-Host "Loading environment variables..." -ForegroundColor Yellow
Import-DotEnv -Path $envFile

# Set the same defaults used by the Airflow DAG
if ([string]::IsNullOrWhiteSpace($env:BQ_DATASET_RAW)) {
    $env:BQ_DATASET_RAW = "housing_raw"
}

if ([string]::IsNullOrWhiteSpace($env:BQ_DATASET_ANALYTICS)) {
    $env:BQ_DATASET_ANALYTICS = "housing_analytics"
}

if ([string]::IsNullOrWhiteSpace($env:BQ_LOCATION)) {
    $env:BQ_LOCATION = "US"
}

# Validate the variables required by the Airflow DAG
$requiredVariables = @(
    "GCP_PROJECT_ID",
    "GCS_BUCKET_RAW",
    "AIRFLOW_ADMIN_PASSWORD",
    "AIRFLOW_WEBSERVER_SECRET_KEY"
)

$missingVariables = @()

foreach ($variableName in $requiredVariables) {
    $variableValue = [Environment]::GetEnvironmentVariable(
        $variableName,
        [EnvironmentVariableTarget]::Process
    )

    if ([string]::IsNullOrWhiteSpace($variableValue)) {
        $missingVariables += $variableName
    }
}

if ($missingVariables.Count -gt 0) {
    throw "The following required environment variables are missing from .env: $($missingVariables -join ', ')"
}

# Resolve the Google service-account credentials path
$credentialsPath = $env:GOOGLE_APPLICATION_CREDENTIALS

if ([string]::IsNullOrWhiteSpace($credentialsPath)) {
    $credentialsPath = $env:GOOGLE_APPLICATION_CREDENTIALS_HOST
}

if (-not [string]::IsNullOrWhiteSpace($credentialsPath)) {
    if (-not [System.IO.Path]::IsPathRooted($credentialsPath)) {
        $credentialsPath = Join-Path $ProjectDir $credentialsPath
    }

    if (-not (Test-Path $credentialsPath)) {
        throw "The Google service-account file was not found: $credentialsPath"
    }

    $credentialsPath = (Resolve-Path $credentialsPath).Path
    $env:GOOGLE_APPLICATION_CREDENTIALS = $credentialsPath
}
else {
    Write-Host "GOOGLE_APPLICATION_CREDENTIALS is not set." -ForegroundColor Yellow
    Write-Host "Airflow and dbt will attempt to use Google Application Default Credentials." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Configuration loaded:" -ForegroundColor Cyan
Write-Host "GCP project:          $env:GCP_PROJECT_ID"
Write-Host "Raw GCS bucket:       $env:GCS_BUCKET_RAW"
Write-Host "Raw BigQuery dataset: $env:BQ_DATASET_RAW"
Write-Host "Analytics dataset:    $env:BQ_DATASET_ANALYTICS"
Write-Host "BigQuery location:    $env:BQ_LOCATION"

# 2. Install Python dependencies
Write-Host ""
Write-Host "Installing Python dependencies..." -ForegroundColor Yellow

$airflowRequirementsFile = Join-Path $ProjectDir "requirements-airflow.txt"
$dbtRequirementsFile = Join-Path $ProjectDir "requirements-dbt.txt"
$airflowConstraintsUrl = "https://raw.githubusercontent.com/apache/airflow/constraints-2.8.0/constraints-3.11.txt"

if (-not (Test-Path $airflowRequirementsFile)) {
    throw "Airflow requirements were not found: $airflowRequirementsFile"
}

if (-not (Test-Path $dbtRequirementsFile)) {
    throw "dbt requirements were not found: $dbtRequirementsFile"
}

python -m pip install --upgrade pip

if ($LASTEXITCODE -ne 0) {
    throw "Failed to upgrade pip."
}

python -m pip install `
    -r $airflowRequirementsFile `
    --constraint $airflowConstraintsUrl

if ($LASTEXITCODE -ne 0) {
    throw "Failed to install Airflow dependencies."
}

# dbt 1.7 requires pathspec < 0.12, so install it after the constrained
# Airflow phase. Airflow accepts the resulting shared pathspec version.
python -m pip install -r $dbtRequirementsFile

if ($LASTEXITCODE -ne 0) {
    throw "Failed to install dbt dependencies."
}

python -m pip check

if ($LASTEXITCODE -ne 0) {
    throw "The installed Python dependencies are inconsistent."
}

# Confirm that the required command-line tools are available
$requiredCommands = @(
    "airflow",
    "dbt",
    "terraform"
)

foreach ($command in $requiredCommands) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "The '$command' command is not available. Check requirements.txt or your PATH."
    }
}

# 3. Set up the dbt profiles directory
Write-Host ""
Write-Host "Setting up dbt profiles..." -ForegroundColor Yellow

$dbtHome = Join-Path $env:USERPROFILE ".dbt"
$sourceProfile = Join-Path $ProjectDir "profiles.yml"
$destinationProfile = Join-Path $dbtHome "profiles.yml"

if (-not (Test-Path $sourceProfile)) {
    throw "profiles.yml was not found: $sourceProfile"
}

if (-not (Test-Path $dbtHome)) {
    New-Item -ItemType Directory -Path $dbtHome -Force | Out-Null
}

Copy-Item $sourceProfile $destinationProfile -Force

# 4. Configure Airflow
Write-Host ""
Write-Host "Configuring Airflow..." -ForegroundColor Yellow

$env:AIRFLOW_HOME = Join-Path $env:USERPROFILE "airflow"
$env:AIRFLOW__CORE__DAGS_FOLDER = Join-Path $ProjectDir "dags"
$env:AIRFLOW__WEBSERVER__SECRET_KEY = $env:AIRFLOW_WEBSERVER_SECRET_KEY

if (-not (Test-Path $env:AIRFLOW_HOME)) {
    New-Item -ItemType Directory -Path $env:AIRFLOW_HOME -Force | Out-Null
}

if (-not (Test-Path $env:AIRFLOW__CORE__DAGS_FOLDER)) {
    throw "The Airflow DAG directory was not found: $env:AIRFLOW__CORE__DAGS_FOLDER"
}

Write-Host "Airflow home: $env:AIRFLOW_HOME"
Write-Host "Airflow DAGs: $env:AIRFLOW__CORE__DAGS_FOLDER"

# Initialize or migrate the Airflow metadata database
Write-Host "Initializing the Airflow database..." -ForegroundColor Yellow

airflow db migrate

if ($LASTEXITCODE -ne 0) {
    Write-Host "The 'airflow db migrate' command failed. Trying 'airflow db init'..." -ForegroundColor Yellow

    airflow db init

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to initialize the Airflow metadata database."
    }
}

# 5. Recreate the local Airflow administrator with the configured password
Write-Host ""
Write-Host "Refreshing the Airflow administrator account..." -ForegroundColor Yellow

airflow users delete --username airflow 2>$null

airflow users create `
    --username airflow `
    --password $env:AIRFLOW_ADMIN_PASSWORD `
    --firstname Airflow `
    --lastname Admin `
    --role Admin `
    --email airflow@example.com

if ($LASTEXITCODE -ne 0) {
    throw "Failed to create the Airflow administrator account."
}

# 6. Create the Airflow Variables required by the DAG
Write-Host ""
Write-Host "Creating Airflow variables..." -ForegroundColor Yellow

$airflowVariables = @{
    "GCP_PROJECT_ID"       = $env:GCP_PROJECT_ID
    "GCS_BUCKET_RAW"       = $env:GCS_BUCKET_RAW
    "BQ_DATASET_RAW"       = $env:BQ_DATASET_RAW
    "BQ_DATASET_ANALYTICS" = $env:BQ_DATASET_ANALYTICS
    "BQ_LOCATION"          = $env:BQ_LOCATION
}

foreach ($entry in $airflowVariables.GetEnumerator()) {
    airflow variables set $entry.Key $entry.Value

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create the Airflow variable '$($entry.Key)'."
    }
}

# 7. Configure the google_cloud_default Airflow connection
Write-Host ""
Write-Host "Configuring the google_cloud_default Airflow connection..." -ForegroundColor Yellow

$connectionExtra = @{
    project = $env:GCP_PROJECT_ID
}

if (-not [string]::IsNullOrWhiteSpace($credentialsPath)) {
    $connectionExtra["key_path"] = $credentialsPath
}

$connectionExtraJson = $connectionExtra | ConvertTo-Json -Compress

# Remove the existing connection so that its configuration can be refreshed
airflow connections get google_cloud_default *> $null

if ($LASTEXITCODE -eq 0) {
    airflow connections delete google_cloud_default *> $null

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to replace the existing google_cloud_default connection."
    }
}

airflow connections add google_cloud_default `
    --conn-type google_cloud_platform `
    --conn-extra $connectionExtraJson

if ($LASTEXITCODE -ne 0) {
    throw "Failed to create the google_cloud_default Airflow connection."
}

# 8. Initialize Terraform
Write-Host ""
Write-Host "Initializing Terraform..." -ForegroundColor Yellow

$terraformDirectory = Join-Path $ProjectDir "terraform"

if (-not (Test-Path $terraformDirectory)) {
    throw "The Terraform directory was not found: $terraformDirectory"
}

Push-Location $terraformDirectory

try {
    terraform init

    if ($LASTEXITCODE -ne 0) {
        throw "Terraform initialization failed."
    }

    # Validate the Terraform files without creating resources
    terraform validate

    if ($LASTEXITCODE -ne 0) {
        throw "Terraform validation failed."
    }
}
finally {
    Pop-Location
}

# 9. Test dbt configuration and GCP connectivity
Write-Host ""
Write-Host "Testing dbt configuration and connectivity..." -ForegroundColor Yellow

dbt debug `
    --project-dir $ProjectDir `
    --profiles-dir $dbtHome

if ($LASTEXITCODE -ne 0) {
    throw "dbt could not connect successfully. Review profiles.yml and your GCP credentials."
}

Write-Host ""
Write-Host "Setup completed successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Review terraform\terraform.tfvars."
Write-Host "2. Run: cd terraform"
Write-Host "3. Run: terraform plan"
Write-Host "4. Run: terraform apply"
Write-Host "5. Return to the project directory."
Write-Host "6. Run: airflow standalone"
Write-Host "7. Open Airflow at http://localhost:8080"
Write-Host "8. Enable and run the housing_analytics_pipeline DAG."
