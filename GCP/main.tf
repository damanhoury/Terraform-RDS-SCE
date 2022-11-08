provider "google" {
  credentials = file(var.credential_file)
  project     = var.project_name
  region      = var.region
  zone        = var.zone
}

resource "google_spanner_instance" "SCE-DEMO-SPANNER" {
  config       = "regional-${var.region}"
  display_name = "SCE-DEMO-SPANNER"
  num_nodes    = 1
}


// create demo database along with 2 Demo Tables

resource "google_spanner_database" "SCE-DEMODB" {
  instance = google_spanner_instance.SCE-DEMO-SPANNER.name
  name     = "demodb"
  deletion_protection=false
   ddl = [
    "CREATE TABLE DEMO_TAB_1 (t1 INT64 NOT NULL,) PRIMARY KEY(t1)",
    "CREATE TABLE DEMO_TAB_2 (t2 INT64 NOT NULL,) PRIMARY KEY(t2)",
  ]
}