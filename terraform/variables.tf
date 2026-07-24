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
  description = "Environment name (dev, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be either 'dev' or 'prod'."
  }
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
