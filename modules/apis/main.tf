variable "project" {}

# enable APIs

resource "google_project_service" "artifact_registry_api" {
  project = var.project
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "cloud_build_api" {
  project = var.project
  service = "cloudbuild.googleapis.com"
}

resource "google_project_service" "cloud_resource_manager_api" {
  project = var.project
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "compute_api" {
  project = var.project
  service = "compute.googleapis.com"
}

resource "google_project_service" "cloud_dns_api" {
  project = var.project
  service = "domains.googleapis.com"
}

resource "google_project_service" "iam_api" {
  project = var.project
  service = "iam.googleapis.com"
}

resource "google_project_service" "network_management_api" {
  project = var.project
  service = "networkmanagement.googleapis.com"
}

resource "google_project_service" "cloud_run_api" {
  project = var.project
  service = "run.googleapis.com"
}

resource "google_project_service" "secret_manager_api" {
  project = var.project
  service = "secretmanager.googleapis.com"
}

resource "google_project_service" "sevice_networking_api" {
  project = var.project
  service = "servicenetworking.googleapis.com"
}

resource "google_project_service" "sql_admin_api" {
  project = var.project
  service = "sqladmin.googleapis.com"
}

resource "google_project_service" "serverless_vpc_access_api" {
  project = var.project
  service = "vpcaccess.googleapis.com"
}
