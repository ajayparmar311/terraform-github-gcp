# Initial local backend for bootstrapping
terraform {
  backend "local" {}
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "tf_state" {
  name          = var.bucket_name
  location      = var.location
  storage_class = "STANDARD"
  force_destroy = false  # Prevent accidental deletion

  # Essential for state recovery
  versioning {
    enabled = true
  }

  # Security best practices
  uniform_bucket_level_access = true

  # Add labels for better management
  labels = {
    purpose    = "terraform-state"
    managed-by = "terraform"
  }

  # Critical protection for state bucket
  lifecycle {
    prevent_destroy = true
  }
}

# Optional: IAM binding for your service account
resource "google_storage_bucket_iam_binding" "admin" {
  bucket = google_storage_bucket.tf_state.name
  role   = "roles/storage.admin"
  members = [
    "serviceAccount:${var.service_account_email}",
  ]
}
