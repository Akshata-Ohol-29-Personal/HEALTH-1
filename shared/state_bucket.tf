provider "google" {
  project     = var.project
}

module "state_bucket" {
  source = "../../../modules/state_bucket"
  project = var.project
}

output "state_bucket" {
  value = module.state_bucket.state_bucket
}
