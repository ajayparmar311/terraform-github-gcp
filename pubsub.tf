resource "google_pubsub_topic" "events_topic" {
  name    = "events-topic"
  labels  = var.labels
}

# Pub/Sub subscription for testing (optional)
resource "google_pubsub_subscription" "events_subscription" {
  name  = "events-subscription"
  topic = google_pubsub_topic.events_topic.name
  labels = var.labels

  ack_deadline_seconds = 30
  message_retention_duration = "604800s" # 7 days

  depends_on = [google_pubsub_topic.events_topic]
}


# Create Pub/Sub Topic
resource "google_pubsub_topic" "otel_metrics" {
  name = "otel-metrics"
  project = var.project_id
}

# Create BigQuery Dataset
resource "google_bigquery_dataset" "otel_metrics" {
  dataset_id = "otel_metrics"
  project = var.project_id
  location      = var.region
  labels        = var.labels
  
    # Set default table expiration (optional)
  default_table_expiration_ms = 3600000 * 24 * 30 # 30 days

  lifecycle {
    prevent_destroy = false
  }
}



# BigQuery Table
resource "google_bigquery_table" "events_table" {
  dataset_id = google_bigquery_dataset.otel_metrics.dataset_id
  table_id   = var.table_id

  schema = <<EOF
[
  {
    "name": "store_id",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Unique identifier for the store"
  },
  {
    "name": "timestamp",
    "type": "TIMESTAMP",
    "mode": "REQUIRED",
    "description": "Event timestamp in UTC"
  },
  {
    "name": "app_info",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Application information"
  },
  {
    "name": "message_id",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Message identifier"
  },
  {
    "name": "event",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Event type"
  },
  {
    "name": "event_value",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Event value details"
  },
  {
    "name": "insert_id",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Unique insert ID for deduplication"
  },
  {
    "name": "processing_time",
    "type": "TIMESTAMP",
    "mode": "NULLABLE",
    "description": "Time when event was processed by Dataflow"
  }
]
EOF

  time_partitioning {
    type  = "DAY"
    field = "timestamp"
  }

  clustering = ["store_id", "event", "timestamp"]

  labels = var.labels

  deletion_protection = false
  depends_on = [google_bigquery_dataset.otel_metrics]
}



resource "google_bigquery_table" "otel_metrics_table" {
  dataset_id = google_bigquery_dataset.otel_metrics.dataset_id
  table_id   = "otel_metrics_table"

  schema = <<EOF
[
  {
    "name": "store_id",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "metric_name",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "timestamp",
    "type": "INTEGER",
    "mode": "REQUIRED"
  },
  {
    "name": "value",
    "type": "FLOAT",
    "mode": "NULLABLE"
  },
  {
    "name": "attributes",
    "type": "JSON",
    "mode": "NULLABLE"
  },
  {
    "name": "resource",
    "type": "JSON",
    "mode": "NULLABLE"
  },
  {
    "name": "insert_id",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "dummy1",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "dummy2",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "dummy3",
    "type": "STRING",
    "mode": "NULLABLE"
  },
]
EOF

  # Optional: Set partitioning (by timestamp in days)
  time_partitioning {
    type  = "DAY"
    field = "timestamp"
  }

  # Optional: Set clustering for better query performance
  clustering = ["store_id", "metric_name"]

  labels = var.labels
  deletion_protection = false
  depends_on = [google_bigquery_dataset.otel_metrics]
}




# IAM role for Dataflow service account to write to BigQuery
resource "google_bigquery_dataset_iam_member" "dataflow_writer" {
  dataset_id = google_bigquery_dataset.otel_metrics.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${var.otel-metrics-sa}"
}


# Storage bucket for Dataflow temp files
resource "google_storage_bucket" "dataflow_temp_bucket" {
  name          = "${var.project_id}-dataflow-temp"
  location      = var.region
  force_destroy = true
  labels        = var.labels

  uniform_bucket_level_access = true

  lifecycle {
    prevent_destroy = false
  }
}

