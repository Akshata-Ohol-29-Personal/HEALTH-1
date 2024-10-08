variable "env" {}
variable "network" {}
variable "project" {}
variable "zone" {}
variable "cloud_sql_instance" {}

resource "google_service_account" "bastion" {
  account_id   = "bastion-${var.env}"
  display_name = "Bastion ${var.env} service account"
}

resource "google_project_iam_member" "cloud_sql_client" {
  project = var.project
  role = "roles/cloudsql.client"
  member = "serviceAccount:${google_service_account.bastion.email}"
}

data "local_file" "bastion_init" {
  filename = "../../modules/bastion/bastion_init.sh"
}

data "local_file" "looker_pubkey" {
  filename = "../../ssh/looker/id_rsa.pub"
}

resource "google_compute_instance" "bastion" {
  name = "bastion-${var.env}"
  machine_type = "e2-micro"
  zone = var.zone
  project = var.project
  tags = ["ssh"]
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = var.network
    access_config {}
  }

  service_account {
    email = google_service_account.bastion.email
    scopes = ["sql-admin"]
  }

  metadata = {
    sql_name = var.cloud_sql_instance.connection_name
    looker_pubkey = data.local_file.looker_pubkey.content
  }

  metadata_startup_script = data.local_file.bastion_init.content
}

resource "google_compute_firewall" "ssh" {
  project     = var.project
  name        = "bastion-ssh"
  network     = var.network

  allow {
    protocol  = "tcp"
    ports     = ["22"]
  }

  target_tags = ["ssh"]
  source_ranges = ["0.0.0.0/0"]
}

output "instance" {
  value = google_compute_instance.bastion
}
