# Terraform – GCP Infrastructure

This module provisions the minimal infrastructure required for the
housing analytics pipeline.

## Resources
- BigQuery dataset for raw data ingestion
- BigQuery dataset for analytics and marts
- (Optional) Cloud Storage bucket for raw files

## Usage
```bash
terraform init
terraform plan
terraform apply
