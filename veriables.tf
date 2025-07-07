variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "topic_name" {
  description = "The name of the Pub/Sub topic"
  type        = string
  default     = "my-topic"
}

variable "bucket_name" {
  description = "The name for the state bucket (must be globally unique)"
  type        = string
}

variable "location" {
  description = "The bucket location"
  type        = string
  default     = "US"
}

variable "service_account_email" {
  description = "Email of the service account that will access the bucket"
  type        = string
}
