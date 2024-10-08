data "local_file" "signoz_init" {
  filename = "signoz_init.sh"
}

resource "google_compute_instance" "signoz" {
  name                      = "signoz"
  machine_type              = "e2-medium"
  zone                      = var.zone
  project                   = var.project
  tags                      = ["ssh", "http"]
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = module.cloud_sql.private_network.name
    access_config {}
  }

  metadata_startup_script = data.local_file.signoz_init.content
}

resource "google_compute_firewall" "http" {
  project = var.project
  name    = "http"
  network = module.cloud_sql.private_network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  target_tags   = ["http"]
  source_ranges = ["0.0.0.0/0"]
}

output "signoz" {
  value = google_compute_instance.signoz
  sensitive = true
}
