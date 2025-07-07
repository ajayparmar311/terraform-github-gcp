terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }

  # Optional: Remote state in GCS (recommended)
#  backend "gcs" {
#    bucket = "your-tf-state-bucket"  # From TF_STATE_BUCKET secret
#    prefix = "terraform/pubsub-state"
#  }
#}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_pubsub_topic" "example_topic" {
  name = var.topic_name
  
  labels = {
    environment = "production"
    managed-by  = "terraform"
    repo        = "github.com/terraform-github-gcp"
  }
}
