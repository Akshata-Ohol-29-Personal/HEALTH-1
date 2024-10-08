variable "project" {}

resource "google_storage_bucket" "tfstate" {
  name          = "${var.project}-tfstate"
  force_destroy = true
  location      = "US"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}

output "state_bucket" {
  value = google_storage_bucket.tfstate
}
