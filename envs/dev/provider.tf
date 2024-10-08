terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
  backend "gcs" {
    prefix = "terraform/state"
    bucket = "precise-formula-368918-tfstate"
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}
