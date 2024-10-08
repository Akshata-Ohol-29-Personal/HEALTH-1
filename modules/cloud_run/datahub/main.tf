variable "db_connection_name" {}
variable "db_host" {}
variable "db_password" {}
variable "env" {}
variable "private_network" {}
variable "project" {}
variable "region" {}
variable "phx_host" {}

resource "google_service_account" "datahub_cloud_run" {
  account_id   = "datahub-cloud-run"
  display_name = "Datahub Cloud Run service account"
}

resource "google_vpc_access_connector" "connector" {
  name          = "vpc-con"
  ip_cidr_range = "10.8.0.0/28"
  network       = var.private_network.name
}

resource "google_cloud_run_service" "datahub" {
  name     = "datahub-${var.env}"
  location = var.region
  depends_on = [
    google_vpc_access_connector.connector,
    google_service_account.datahub_cloud_run
  ]

  template {
    spec {
      service_account_name = google_service_account.datahub_cloud_run.email

      containers {
        image = "${var.region}-docker.pkg.dev/${var.project}/datahub/release:latest"

        env {
          name  = "APTIBLE_GIT_REF"
          value = "deadbee"
        }
        env {
          name  = "DATABASE_URL"
          value = "postgres://datahub:${var.db_password}@${var.db_host}/datahub-${var.env}?ssl=true"
        }
        env {
          name  = "FORCE_SSL"
          value = "true"
        }
        env {
          name  = "OTEL_EXPORT_ENDPOINT"
          value = "http://100.126.92.80:4319"
        }
        env {
          name  = "OTEL_SERVICE_NAME"
          value = "datahub-${var.env}"
        }
        env {
          name  = "OTELCOL_METRICS_EXPORTERS"
          value = "otlphttp"
        }
        env {
          name  = "PHX_HOST"
          value = var.phx_host 
        }
        env {
          name  = "RELEASE_LEVEL"
          value = "staging"
        }
        env {
          name  = "SENTRY_DSN"
          value = "https://abc@123.ingest.sentry.io/456"
        }
        env {
          name  = "TAILSCALE_HOSTNAME"
          value = "datahub-${var.env}"
        }
        env {
          name = "DATAHUB_CLOAK_KEY"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = "DATAHUB_CLOAK_KEY"
            }
          }
        }
        env {
          name  = "DATAHUB_METRICS_AUTH_TOKEN"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = "DATAHUB_METRICS_AUTH_TOKEN"
            }
          }
        }
        env {
          name  = "DATAHUB_SMTP_PASSWORD"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = "DATAHUB_SMTP_PASSWORD"
            }
          }
        }
        env {
          name = "GOOGLE_OAUTH_CLIENT_ID"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = "GOOGLE_OAUTH_CLIENT_ID"
            }
          }
        }
        env {
          name = "GOOGLE_OAUTH_CLIENT_SECRET"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = "GOOGLE_OAUTH_CLIENT_SECRET"
            }
          }
        }
        env {
          name = "SECRET_KEY_BASE"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = "SECRET_KEY_BASE"
            }
          }
        }
        env {
          name = "TAILSCALE_AUTH_KEY"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = "TAILSCALE_AUTH_KEY"
            }
          }
        }
        env {
          name = "GOOGLE_CLOUD_SQL_CERT"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = "GOOGLE_CLOUD_SQL_CERT"
            }
          }
        }
        env {
          name = "GOOGLE_CLOUD_SQL_PRIVKEY"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = "GOOGLE_CLOUD_SQL_PRIVKEY"
            }
          }
        }
        env {
          name = "GOOGLE_CLOUD_SQL_CA_CERT"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = "GOOGLE_CLOUD_SQL_CA_CERT"
            }
          }
        }

        ports {
          container_port = 4000
        }

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
        "run.googleapis.com/cloudsql-instances" = var.db_connection_name
        "run.googleapis.com/cpu-throttling" = false
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.connector.id
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

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.datahub.location
  project  = google_cloud_run_service.datahub.project
  service  = google_cloud_run_service.datahub.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_cloud_run_domain_mapping" "datahub" {
  location = var.region
  name     = var.phx_host

  metadata {
    namespace = var.project
  }

  spec {
    route_name = google_cloud_run_service.datahub.name
  }
}

output "service_account" {
  value = google_service_account.datahub_cloud_run
}

output "service" {
  value = google_cloud_run_service.datahub
}

output "vpc_access_connector" {
  value = google_vpc_access_connector.connector
}
