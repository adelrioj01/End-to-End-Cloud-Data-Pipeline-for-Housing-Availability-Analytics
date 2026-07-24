resource "google_bigquery_dataset" "raw" {
  dataset_id = "housing_raw_${var.environment}"
  location   = var.bq_location
}

resource "google_bigquery_dataset" "analytics" {
  dataset_id = "housing_analytics_${var.environment}"
  location   = var.bq_location
}

resource "google_storage_bucket" "raw_data" {
  name     = "${var.project_id}-housing-raw-${var.environment}"
  location = var.region

  uniform_bucket_level_access = true
}
