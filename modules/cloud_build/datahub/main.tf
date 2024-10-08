variable "cloud_run_sa" {}
variable "env" {}
variable "project" {}

# create the service account and grant it permissions

resource "google_service_account" "datahub_cloud_build" {
  account_id   = "datahub-cloud-build"
  display_name = "Datahub Cloud Build service account"
}

data "google_secret_manager_secret" "oban_key_fingerprint" {
  secret_id = "OBAN_KEY_FINGERPRINT"
}

resource "google_secret_manager_secret_iam_member" "cloud_build_oban_key_fingerprint_access" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.datahub_cloud_build.email}"
  secret_id = data.google_secret_manager_secret.oban_key_fingerprint.id
}

data "google_secret_manager_secret" "oban_license_key" {
  secret_id = "OBAN_LICENSE_KEY"
}

resource "google_secret_manager_secret_iam_member" "cloud_build_oban_license_key_access" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.datahub_cloud_build.email}"
  secret_id = data.google_secret_manager_secret.oban_license_key.id
}

resource "google_project_iam_member" "cloud_build_logging_write" {
  project = var.project
  role = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.datahub_cloud_build.email}"
}

resource "google_project_iam_member" "cloud_build_run_admin" {
  project = var.project
  role = "roles/run.admin"
  member = "serviceAccount:${google_service_account.datahub_cloud_build.email}"
}

resource "google_service_account_iam_member" "cloud_build_acts_as" {
  service_account_id = var.cloud_run_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.datahub_cloud_build.email}"
}

# create the bucket for logs and grant access to service account

resource "google_storage_bucket" "datahub_cloud_build_logs" {
  name          = "datahub-${var.env}-cloud-build-logs"
  force_destroy = true
  location      = "US"
  storage_class = "STANDARD"
  versioning {
    enabled = false
  }
}

resource "google_storage_bucket_iam_member" "datahub_cloud_build_logs" {
  bucket = google_storage_bucket.datahub_cloud_build_logs.name
  role = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.datahub_cloud_build.email}"
}

# fetch the default created cloudbuild bucket and grant access to service account

data "google_storage_bucket" "cloud_build" {
  name = "${var.project}_cloudbuild"
}

resource "google_storage_bucket_iam_member" "datahub_cloud_build" {
  bucket = data.google_storage_bucket.cloud_build.name
  role = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.datahub_cloud_build.email}"
}

# outputs

output "cloud_build_sa" {
  value = google_service_account.datahub_cloud_build
}
