resource "google_bigquery_dataset" "raw" {
  dataset_id = var.raw_dataset_id
  location   = var.bq_location
}

resource "google_bigquery_dataset" "analytics" {
  dataset_id = var.analytics_dataset_id
  location   = var.bq_location
}

resource "google_storage_bucket" "raw_data" {
  name     = var.raw_storage_bucket_name
  location = var.bucket_location

  uniform_bucket_level_access = true
}
