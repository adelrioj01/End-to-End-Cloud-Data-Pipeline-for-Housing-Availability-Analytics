output "raw_dataset" {
  value = google_bigquery_dataset.raw.dataset_id
}

output "analytics_dataset" {
  value = google_bigquery_dataset.analytics.dataset_id
}
