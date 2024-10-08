provider "google" {
  project = var.project
}

module "cloud_build" {
  source  = "../../../modules/cloud_build/ops"
  project = var.project
  env     = var.env
}

output "cloud_build" {
  value = module.cloud_build
}
