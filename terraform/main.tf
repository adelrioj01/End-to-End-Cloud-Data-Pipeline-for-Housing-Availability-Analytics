resource "google_bigquery_dataset" "raw" {
  dataset_id = "housing_raw"
  location   = "US"
}

resource "google_bigquery_dataset" "analytics" {
  dataset_id = "housing_analytics"
  location   = "US"
}

resource "google_storage_bucket" "raw_data" {
  name     = "${var.project_id}-housing-raw"
  location = "US"

  uniform_bucket_level_access = true
}
