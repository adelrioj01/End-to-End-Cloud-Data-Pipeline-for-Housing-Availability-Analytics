variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment label used by downstream configuration"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be either 'dev' or 'prod'."
  }
}

variable "raw_dataset_id" {
  description = "BigQuery dataset ID for raw source tables"
  type        = string
  default     = "housing_raw"
}

variable "analytics_dataset_id" {
  description = "BigQuery dataset ID for dbt models and analytics marts"
  type        = string
  default     = "housing_analytics"
}

variable "raw_storage_bucket_name" {
  description = "Globally unique Cloud Storage bucket used for raw CSV files"
  type        = string
}

variable "bucket_location" {
  description = "Cloud Storage bucket location"
  type        = string
  default     = "US"
}

variable "bq_location" {
  description = "BigQuery location"
  type        = string
  default     = "US"

  validation {
    condition     = contains(["US", "EU"], var.bq_location)
    error_message = "bq_location must be either 'US' or 'EU'."
  }
}
