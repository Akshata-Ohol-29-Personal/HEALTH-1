terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
  backend "gcs" {
    prefix = "terraform/state"
    bucket = "yuvo-production-tfstate"
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}
