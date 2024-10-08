variable "env" {}
variable "project" {}
variable "region" {}

# create the service account and grant it permissions

resource "google_service_account" "ph_service_cloud_build" {
  account_id   = "ph_service-cloud-build"
  display_name = "PH Service Cloud Build service account"
}

resource "google_project_iam_member" "ph_service_cloud_build_logging_write" {
  project = var.project
  role = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.ph_service_cloud_build.email}"
}

# create the image repo

resource "google_artifact_registry_repository" "ph_service" {
  location = var.region
  repository_id = "ph_service"
  format = "DOCKER"
}

resource "google_artifact_registry_repository_iam_member" "cloud_build" {
  project = var.project
  location = google_artifact_registry_repository.ph_service.location
  repository = google_artifact_registry_repository.ph_service.name
  role = "roles/artifactregistry.repoAdmin"
  member = "serviceAccount:${google_service_account.ph_service_cloud_build.email}"
}

# create the bucket for logs and grant access to service account

resource "google_storage_bucket" "ph_service_cloud_build_logs" {
  name          = "ph_service-${var.env}-cloud-build-logs"
  force_destroy = true
  location      = "US"
  storage_class = "STANDARD"
  versioning {
    enabled = false
  }
}

resource "google_storage_bucket_iam_member" "ph_service_cloud_build_logs" {
  bucket = google_storage_bucket.ph_service_cloud_build_logs.name
  role = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.ph_service_cloud_build.email}"
}

# fetch the default created cloudbuild bucket and grant access to service account

data "google_storage_bucket" "cloud_build" {
  name = "${var.project}_cloudbuild"
}

resource "google_storage_bucket_iam_member" "ph_service_cloud_build" {
  bucket = data.google_storage_bucket.cloud_build.name
  role = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.ph_service_cloud_build.email}"
}


resource "google_cloudbuild_trigger" "apply_trigger" {
  service_account = google_service_account.ph_service_cloud_build.id
  filename        = "cloudbuild.yaml"
  name            = "ph_service-${var.env}-apply-trigger"

  depends_on = [
    google_project_iam_member.ph_service_cloud_build_logging_write
  ]

  github {
    owner = "Yuvohealth"
    name  = "ph_service"
    push {
      branch = "^main$"
    }
  }

  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"

  substitutions = {
    _ENV = var.env
  }
}

# outputs

output "cloud_build_sa" {
  value = google_service_account.ph_service_cloud_build
}

output "docker_repo" {
  value = google_artifact_registry_repository.ph_service
}