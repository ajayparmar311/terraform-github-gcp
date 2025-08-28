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
  member  = "serviceAccount:dataflow-service-account@my-kube-project-429018.iam.gserviceaccount.com"
}


