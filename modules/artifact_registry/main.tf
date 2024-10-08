variable "project" {}
variable "region" {}
variable "cloud_build_sa_email" {}

resource "google_artifact_registry_repository" "datahub" {
  location = var.region
  repository_id = "datahub"
  format = "DOCKER"
}

output "docker_repo" {
  value = google_artifact_registry_repository.datahub
}

resource "google_artifact_registry_repository_iam_member" "cloud_build" {
  project = var.project
  location = google_artifact_registry_repository.datahub.location
  repository = google_artifact_registry_repository.datahub.name
  role = "roles/artifactregistry.repoAdmin"
  member = "serviceAccount:${var.cloud_build_sa_email}"
}
