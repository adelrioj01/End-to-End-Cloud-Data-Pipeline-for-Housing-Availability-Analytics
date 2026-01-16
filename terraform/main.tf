resource "google_bigquery_dataset" "raw" {
  dataset_id = "housing_raw"
  location   = "EU"
}

resource "google_bigquery_dataset" "analytics" {
  dataset_id = "housing_analytics"
  location   = "EU"
}

resource "google_storage_bucket" "raw_data" {
  name     = "${var.project_id}-housing-raw"
  location = "EU"

  uniform_bucket_level_access = true
}
