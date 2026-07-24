output "raw_dataset_id" {
  value       = google_bigquery_dataset.raw.dataset_id
  description = "Raw dataset ID"
}

output "analytics_dataset_id" {
  value       = google_bigquery_dataset.analytics.dataset_id
  description = "Analytics dataset ID"
}

output "raw_storage_bucket" {
  value       = google_storage_bucket.raw_data.name
  description = "Raw data storage bucket name"
}

output "raw_storage_bucket_url" {
  value       = "gs://${google_storage_bucket.raw_data.name}"
  description = "Raw data storage bucket URL"
}

output "environment" {
  value       = var.environment
  description = "Deployed environment"
}
