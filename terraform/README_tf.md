# Terraform – GCP Infrastructure

This module provisions the minimal infrastructure required for the
housing analytics pipeline.

## Resources

- BigQuery dataset for raw data ingestion
- BigQuery dataset for analytics and marts
- Cloud Storage bucket for raw files

Resource IDs are explicit variables rather than being derived from the
environment name. This prevents Terraform from proposing destructive dataset
or bucket replacements when it adopts infrastructure that was created with
stable names such as `housing_raw` and `housing_analytics`.

## Usage
```bash
terraform init
terraform plan
terraform apply
```

Copy `terraform.tfvars.example` to `terraform.tfvars` and set the real project
and globally unique bucket name. Always review the complete plan before an
apply. Renaming a dataset, changing a bucket name, or changing a bucket
location forces resource replacement.
