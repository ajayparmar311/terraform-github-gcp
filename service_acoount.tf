# Pub/Sub permissions
resource "google_project_iam_member" "pubsub_editor" {
  project = var.project_id
  role    = "roles/pubsub.editor"
  member  = "serviceAccount:${var.otel-metrics-sa}"
}

# BigQuery permissions
resource "google_project_iam_member" "bq_admin" {
  project = var.project_id
  role    = "roles/bigquery.admin"
  member  = "serviceAccount:${var.otel-metrics-sa}"
}

resource "google_project_iam_member" "bq_data_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${var.otel-metrics-sa}"
}


resource "google_service_account" "dataflow_service_account" {
  account_id   = "dataflow_service_account"   # must be unique within the project
  display_name = "dataflow_service_account"
  description  = "Service account for Terraform example"
}


# IAM roles for Dataflow service account
resource "google_project_iam_member" "dataflow_roles" {
  for_each = toset([
    "roles/dataflow.worker",
    "roles/pubsub.subscriber",
    "roles/storage.admin",
    "roles/bigquery.dataEditor",
    "roles/iam.serviceAccountUser"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.dataflow_service_account.email}"
  depends_on = [google_service_account.]
}


