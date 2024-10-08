variable "datahub_cloud_build_sa" {}
variable "env" {}
variable "region" {}

# non-prod build trigger - match on push to env branch

resource "google_cloudbuild_trigger" "image_trigger" {
  service_account = var.datahub_cloud_build_sa.id
  filename        = "cloudbuild.yaml"
  name            = "datahub-${var.env}-deploy-trigger"

  github {
    owner = "Yuvohealth"
    name  = "datahub"
    push {
      branch = "^${var.env}$"
    }
  }

  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"

  substitutions = {
    _ENV = var.env
    _REGION = var.region
  }
}
