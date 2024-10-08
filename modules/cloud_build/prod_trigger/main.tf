variable "datahub_cloud_build_sa" {}
variable "region" {}

# PRODUCTION build trigger - match on release version tag

resource "google_cloudbuild_trigger" "image_trigger" {
  service_account = var.datahub_cloud_build_sa.id
  filename        = "cloudbuild.yaml"
  name            = "datahub-prod-deploy-trigger"

  github {
    owner = "Yuvohealth"
    name  = "datahub"
    push {
      tag = "^v\\d+\\.\\d+\\.\\d+$"
    }
  }

  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"

  substitutions = {
    _ENV = "prod"
    _REGION = var.region
  }
}
