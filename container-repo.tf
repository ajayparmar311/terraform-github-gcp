resource "google_artifact_registry_repository" "otel_repo" {
  provider = google-beta
  location      = var.region
  repository_id = "otel-repo"
  description   = "Docker repo for otel loader"
  format        = "DOCKER"

  labels = var.labels
}