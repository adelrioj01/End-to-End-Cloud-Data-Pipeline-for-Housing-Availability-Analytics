resource "google_bigquery_dataset" "raw" {
  dataset_id = "housing_raw"
  location   = "EU"
}

resource "google_bigquery_dataset" "analytics" {
  dataset_id = "housing_analytics"
  location   = "EU"
}
