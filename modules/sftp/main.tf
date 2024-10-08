variable "env" {}
variable "image" {}
variable "network" {}
variable "project" {}
variable "zone" {}

resource "google_service_account" "sftp" {
  account_id   = "sftp-service"
  display_name = "SFTP service account"
}

data "google_secret_manager_secret" "sftp_ssh_host_ed25519_key" {
  secret_id = "SFTP_SSH_HOST_ED25519_KEY"
}

resource "google_secret_manager_secret_iam_member" "sftp_ssh_host_ed25519_key_access" {
  project   = var.project
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.sftp.email}"
  secret_id = data.google_secret_manager_secret.sftp_ssh_host_ed25519_key.id
}

data "google_secret_manager_secret" "sftp_ssh_host_rsa_key" {
  secret_id = "SFTP_SSH_HOST_RSA_KEY"
}

resource "google_secret_manager_secret_iam_member" "sftp_ssh_host_rsa_key_access" {
  project   = var.project
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.sftp.email}"
  secret_id = data.google_secret_manager_secret.sftp_ssh_host_rsa_key.id
}

data "google_secret_manager_secret" "sftp_users" {
  secret_id = "SFTP_USERS"
}

resource "google_secret_manager_secret_iam_member" "sftp_users" {
  project   = var.project
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.sftp.email}"
  secret_id = data.google_secret_manager_secret.sftp_users.id
}

resource "google_project_iam_member" "sftp_logging_write" {
  project = var.project
  role = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.sftp.email}"
}

module "gce-container" {
  source  = "terraform-google-modules/container-vm/google"
  version = "~> 2.0"

  container = {
    image = var.image
    env = [
      {
        name  = "GCS_PROJECT"
        value = var.project
      }
    ]

    volumeMounts = [
      {
        mountPath = "/home"
        name      = "home"
        readOnly  = false
      }
    ]
  }

  volumes = [
    {
      name = "home"

      gcePersistentDisk = {
        pdName = "home"
        fsType = "ext4"
      }
    },
  ]

  restart_policy = "OnFailure"
}

resource "google_compute_disk" "pd" {
  project = var.project
  name    = "sftp-${var.env}-home-disk"
  type    = "pd-ssd"
  zone    = var.zone
  size    = 10
}

resource "google_compute_instance" "sftp" {
  project      = var.project
  name         = "sftp-${var.env}"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = module.gce-container.source_image
    }
  }

  attached_disk {
    source      = google_compute_disk.pd.self_link
    device_name = "home"
    mode        = "READ_WRITE"
  }

  network_interface {
    network = var.network
    access_config {}
  }

  metadata = {
    "gce-container-declaration" = module.gce-container.metadata_value
    "google-logging-enabled"    = true
  }

  labels = {
    container-vm = module.gce-container.vm_container_label
  }

  tags = ["sftp", "ssh"]

  service_account {
    email = google_service_account.sftp.email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

resource "google_compute_firewall" "sftp" {
  project = var.project
  name    = "sftp"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["2222"]
  }

  target_tags   = ["sftp"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_project_metadata_item" "container_logging" {
  key   = "google-logging-enabled"
  value = true
}

output "sftp_ip" {
  value = google_compute_instance.sftp.network_interface[0].access_config[0].nat_ip
}
