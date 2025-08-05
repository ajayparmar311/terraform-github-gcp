

# Create Pub/Sub Topic
resource "google_pubsub_topic" "otel_metrics" {
  name = "otel-metrics"
  project = var.project_id
}

# Create BigQuery Dataset
resource "google_bigquery_dataset" "otel_metrics" {
  dataset_id = "otel_metrics"
  project = var.project_id
  location   = "US"  # Adjust location as needed
}

# Create BigQuery Table (required before creating the subscription sink)

resource "google_bigquery_table" "metrics_table" {
  dataset_id = google_bigquery_dataset.otel_metrics.dataset_id
  table_id   = "metrics_table"
  project = var.project_id
  schema     = file("${path.module}/schemas/metrics_table_schema.json")

}


# Create Pub/Sub Subscription with BigQuery Sink
resource "google_pubsub_subscription" "bigquery_sub" {
  name  = "bigquery-sub"
  project = var.project_id
  topic = google_pubsub_topic.otel_metrics.id

  bigquery_config {
    table = "${google_bigquery_table.metrics_table.project}.${google_bigquery_dataset.otel_metrics.dataset_id}.${google_bigquery_table.metrics_table.table_id}"
    use_topic_schema = false
    write_metadata   = true
  }

  ack_deadline_seconds = 20
}
