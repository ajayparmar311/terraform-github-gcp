resource "google_artifact_registry_repository" "otel_repo" {
  provider = google-beta

  location      = var.region
  repository_id = "otel-repo"
  description   = "Docker repo for otel loader"
  format        = "DOCKER"

  labels = var.labels

  # Optional: Configure cleanup policies
  cleanup_policy_dry_run = false
  cleanup_policies {
    condition {
      older_than = "360d" # Keep images for 1 year
    }
    action = "DELETE"
  }

  # Optional: Enable immutable tags
  mutable_tags = false
}