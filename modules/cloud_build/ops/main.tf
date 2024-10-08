variable "env" {}
variable "project" {}

# service account

resource "google_service_account" "ops_cloud_build" {
  account_id   = "yuvo-ops-cloud-build"
  display_name = "Yuvo Ops Cloud Build service account"
}

# buckets: build, logs

resource "google_storage_bucket" "ops_cloud_build_logs" {
  name          = "yuvo-ops-${var.env}-cloud-build-logs"
  force_destroy = true
  location      = "US"
  storage_class = "STANDARD"
  versioning {
    enabled = false
  }
}

resource "google_storage_bucket" "cloud_build" {
  name          = "${var.project}_cloudbuild"
  force_destroy = false
  location      = "US"
  storage_class = "STANDARD"
  versioning {
    enabled = false
  }
}

# permissions/roles

resource "google_storage_bucket_iam_member" "ops_cloud_build_logs" {
  bucket = google_storage_bucket.ops_cloud_build_logs.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.ops_cloud_build.email}"
}

resource "google_project_iam_member" "ops_cloud_build_logging_write" {
  project = var.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.ops_cloud_build.email}"
}

resource "google_project_iam_member" "ops_cloud_build_editor" {
  project = var.project
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.ops_cloud_build.email}"
}

resource "google_project_iam_member" "ops_cloud_build_artifact_registry_admin" {
  project = var.project
  role    = "roles/artifactregistry.admin"
  member  = "serviceAccount:${google_service_account.ops_cloud_build.email}"
}

resource "google_project_iam_member" "ops_cloud_build_secret_manager_admin" {
  project = var.project
  role    = "roles/secretmanager.admin"
  member  = "serviceAccount:${google_service_account.ops_cloud_build.email}"
}

resource "google_project_iam_member" "ops_cloud_build_project_iam_admin" {
  project = var.project
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:${google_service_account.ops_cloud_build.email}"
}

resource "google_project_iam_member" "ops_cloud_build_compute_network_admin" {
  project = var.project
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${google_service_account.ops_cloud_build.email}"
}

resource "google_project_iam_member" "ops_cloud_build_cloud_sql_admin" {
  project = var.project
  role    = "roles/cloudsql.admin"
  member  = "serviceAccount:${google_service_account.ops_cloud_build.email}"
}

# triggers

resource "google_cloudbuild_trigger" "plan_trigger" {
  service_account = google_service_account.ops_cloud_build.id
  filename        = "plan.yml"
  name            = "ops-${var.env}-plan-trigger"

  depends_on = [
    google_project_iam_member.ops_cloud_build_logging_write
  ]

  github {
    owner = "Yuvohealth"
    name  = "ops"
    pull_request {
      branch = "^${var.env}$"
    }
  }

  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"

  substitutions = {
    _ENV = var.env
  }
}

resource "google_cloudbuild_trigger" "apply_trigger" {
  service_account = google_service_account.ops_cloud_build.id
  filename        = "apply.yml"
  name            = "ops-${var.env}-apply-trigger"

  depends_on = [
    google_project_iam_member.ops_cloud_build_logging_write
  ]

  github {
    owner = "Yuvohealth"
    name  = "ops"
    push {
      branch = "^${var.env}$"
    }
  }

  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"

  substitutions = {
    _ENV = var.env
  }
}

# output

output "cloud_build_service_account" {
  value = google_service_account.ops_cloud_build
}

output "cloud_build_apply_trigger" {
  value = google_cloudbuild_trigger.apply_trigger
}

output "cloud_build_plan_trigger" {
  value = google_cloudbuild_trigger.plan_trigger
}
