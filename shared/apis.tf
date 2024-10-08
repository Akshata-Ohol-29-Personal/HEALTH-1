provider "google" {
  project     = var.project
}

module "apis" {
  source = "../../../modules/apis"
  project = var.project
}
