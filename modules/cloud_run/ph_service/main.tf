variable "env" {}
variable "google_vpc_access_connector" {}
variable "private_network" {}
variable "project" {}
variable "region" {}

resource "google_service_account" "ph_service_cloud_run" {
  account_id   = "ph_service-cloud-run"
  display_name = "PH Service Cloud Run service account"
}

resource "google_cloud_run_service" "ph_service" {
  name     = "ph_service-${var.env}"
  location = var.region
  depends_on = [
    var.google_vpc_access_connector,
    google_service_account.ph_service_cloud_run
  ]

  template {
    spec {
      service_account_name = google_service_account.ph_service_cloud_run.email

      containers {
        command = [
          "cron",
          "-f"
        ]

        image = "${var.region}-docker.pkg.dev/${var.project}/ph_service/release:latest"

       
        resources {
          limits = {
            cpu    = "1000m"
            memory = "2Gi"
          }
        }
      } # end containers
    } # end spec

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = "1"
        "autoscaling.knative.dev/maxScale" = "1"
        "run.googleapis.com/client-name" = "terraform"
        "run.googleapis.com/cpu-throttling" = false
        "run.googleapis.com/vpc-access-connector" = var.google_vpc_access_connector.id
        "run.googleapis.com/vpc-access-egress" = "private-ranges-only"
      }
    }
  } # end template

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true
}

data "google_iam_policy" "auth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "user:kenichi@ratiopbc.com",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "auth" {
  location = google_cloud_run_service.ph_service.location
  project  = google_cloud_run_service.ph_service.project
  service  = google_cloud_run_service.ph_service.name

  policy_data = data.google_iam_policy.auth.policy_data
}

resource "google_cloud_run_domain_mapping" "ph_service" {
  location = var.region
  name     = "${google_cloud_run_service.ph_service.name}.yuvohealth.com"

  metadata {
    namespace = var.project
  }

  spec {
    route_name = google_cloud_run_service.ph_service.name
  }
}

output "service" {
  value = google_cloud_run_service.ph_service
}