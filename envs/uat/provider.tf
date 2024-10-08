terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
  backend "gcs" {
    prefix = "terraform/state"
    bucket = "yuvo-uat-tfstate"
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}
