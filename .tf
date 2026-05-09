[1mdiff --git a/profiles.yml b/profiles.yml[m
[1mindex b577130..035a953 100644[m
[1m--- a/profiles.yml[m
[1m+++ b/profiles.yml[m
[36m@@ -4,7 +4,7 @@[m [mhousing_analytics:[m
     dev:[m
       type: bigquery[m
       method: service-account[m
[31m-      project: your-gcp-project-id[m
[32m+[m[32m      project: housing-analytics-dev[m
       dataset: housing_dev[m
       keyfile: /ruta/a/tu/service_account.json[m
       threads: 4[m
[1mdiff --git a/terraform/main.tf b/terraform/main.tf[m
[1mindex 1f88c0e..38844db 100644[m
[1m--- a/terraform/main.tf[m
[1m+++ b/terraform/main.tf[m
[36m@@ -1,16 +1,16 @@[m
 resource "google_bigquery_dataset" "raw" {[m
   dataset_id = "housing_raw"[m
[31m-  location   = "EU"[m
[32m+[m[32m  location   = "US"[m
 }[m
 [m
 resource "google_bigquery_dataset" "analytics" {[m
   dataset_id = "housing_analytics"[m
[31m-  location   = "EU"[m
[32m+[m[32m  location   = "US"[m
 }[m
 [m
 resource "google_storage_bucket" "raw_data" {[m
   name     = "${var.project_id}-housing-raw"[m
[31m-  location = "EU"[m
[32m+[m[32m  location = "US"[m
 [m
   uniform_bucket_level_access = true[m
 }[m
[1mdiff --git a/terraform/providers.tf b/terraform/providers.tf[m
[1mindex 8b13789..2747e0f 100644[m
[1m--- a/terraform/providers.tf[m
[1m+++ b/terraform/providers.tf[m
[36m@@ -1 +1,14 @@[m
[32m+[m[32mterraform {[m
[32m+[m[32m  required_providers {[m
[32m+[m[32m    google = {[m
[32m+[m[32m      source  = "hashicorp/google"[m
[32m+[m[32m      version = "~> 5.0"[m
[32m+[m[32m    }[m
[32m+[m[32m  }[m
[32m+[m[32m}[m
[32m+[m
[32m+[m[32mprovider "google" {[m
[32m+[m[32m  project = var.project_id[m
[32m+[m[32m  region  = var.region[m
[32m+[m[32m}[m
 [m
