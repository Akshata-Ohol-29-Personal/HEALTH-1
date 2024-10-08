variable "env" {}
variable "region" {}
variable "tier" {
  default = "db-f1-micro"
}

resource "google_compute_network" "private_network" {
  name = "private-network"
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.private_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.private_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_sql_database_instance" "datahub" {
  region           = var.region
  database_version = "POSTGRES_14"

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = var.tier
    database_flags {
      name = "max_connections"
      value = 100
    }
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.private_network.id
      require_ssl     = true
    }
  }
}

resource "google_sql_database" "database" {
  name     = "datahub-${var.env}"
  depends_on = [google_sql_database_instance.datahub]
  instance = google_sql_database_instance.datahub.name
}

resource "random_string" "db_user_password" {
  length           = 30
  special          = true
  override_special = "-_.~"
}

resource "google_sql_user" "db_user" {
  instance = google_sql_database_instance.datahub.name
  name = "datahub"
  password = random_string.db_user_password.result
}

resource "google_sql_ssl_cert" "client_cert" {
  common_name = "datahub-${var.env}"
  instance    = google_sql_database_instance.datahub.name
}

output "db_instance" {
  value = google_sql_database_instance.datahub
}

output "db_password" {
  value = random_string.db_user_password.result
}

output "private_network" {
  value = google_compute_network.private_network
}

output "client_cert" {
  value = google_sql_ssl_cert.client_cert
  sensitive = true
}
