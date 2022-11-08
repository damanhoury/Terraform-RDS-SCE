provider "google" {
  credentials = file(var.credential_file)
  project     = var.project_name
  region      = var.region
  zone        = var.zone
}

resource "google_sql_database_instance" "SCE-DEMO-MSSQL" {
  name                = "sce-demo-mssql"
  database_version    = "SQLSERVER_2019_ENTERPRISE"
  region              = var.region
  deletion_protection = false
  root_password       = "Temp1763"

  settings {
    // for SQL server , tier Must use custom shares
    // it takes the following naming convention : db-custom-NUMBER_OF_CPUS-NUMBER_OF_MB
    // in our case the SQL server instance will have 2 CPU's and 7680 MB

    tier = "db-custom-2-7680"
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

resource "google_sql_database" "SCE-DEMODB" {
  name      = "SCE-DEMODB"
  instance  = google_sql_database_instance.SCE-DEMO-MSSQL.name
}

resource "google_sql_user" "users" {
  name     = "sqladmin"
  instance = google_sql_database_instance.SCE-DEMO-MSSQL.name
  password = "Ch@ngeMe1948"
}

// print out the Public IP of the SQL Server instance

output "rds_ip" {
  value = google_sql_database_instance.SCE-DEMO-MSSQL.public_ip_address
}