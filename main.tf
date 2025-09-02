terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
}

  # Optional: Remote state in GCS (recommended)
  backend "gcs" {
    bucket = "terraform-state-bucket-31594"  # From TF_STATE_BUCKET secret
    prefix = "terraform/pubsub-state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_pubsub_topic" "example_topic" {
  name = var.topic_name
  project = var.project_id
  
  labels = {
    environment = "production"
    managed-by  = "terraform"
  }
}

output "topic_name" {
  value = google_pubsub_topic.example_topic.name
}

output "topic_id" {
  value = google_pubsub_topic.example_topic.id
}
