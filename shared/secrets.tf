provider "google" {
  project = var.project
}

module "secrets" {
  source = "../../../modules/secrets"
}
