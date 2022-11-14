provider "google" {
  credentials = file(var.credential_file)
  project     = var.project_name
  region      = var.region
  zone        = var.zone
}

resource "google_sql_database_instance" "SCE-DEMO-POSTGRESQL" {
  name                = "sce-demo-postgresql"
  database_version    = "POSTGRES_14"
  region              = var.region
  deletion_protection = false

  settings {
  
    tier = "db-g1-small"

    ip_configuration {

    // to enable Public IP , and allow all Connection from any client over internet

      authorized_networks {
        name  = "public_access"
        value = "0.0.0.0/0"
      }
      ipv4_enabled = true
    }
  }
}

resource "google_sql_database" "demodb" {
  name      = "demodb"
  instance  = google_sql_database_instance.SCE-DEMO-POSTGRESQL.name
  charset   = "UTF8"
  collation = "en_US.UTF8"
}

resource "google_sql_user" "users" {
  name     = "root"
  instance = google_sql_database_instance.SCE-DEMO-POSTGRESQL.name
  password = "Welcome1"
}

// print out the Public IP of the PostgreSQL instance

output "rds_ip" {
  value = google_sql_database_instance.SCE-DEMO-POSTGRESQL.public_ip_address
}