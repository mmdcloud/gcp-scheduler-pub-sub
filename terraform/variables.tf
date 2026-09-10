variable "project_id" {
  type        = string
  description = "The GCP project ID where resources will be deployed."
}

variable "location" {
  type        = string
  description = "The GCP region for region-scoped resources (e.g., GCS bucket, Cloud Run Function)."
  default     = "us-central1"
}

variable "iam_roles" {
  type        = list(string)
  description = "List of IAM roles to grant to the default Compute Engine service account."
  default = [
    "roles/logging.logWriter",
    "roles/storage.objectViewer",
    "roles/artifactregistry.writer"
  ]
}

variable "pubsub_config" {
  type = object({
    topic_name                 = string
    message_retention_duration = string
  })
  description = "Configuration parameters for the Pub/Sub topic."
  default = {
    topic_name                 = "event-scheduler-topic"
    message_retention_duration = "86600s"
  }
}

variable "scheduler_config" {
  type = object({
    name        = string
    description = string
    schedule    = string
    payload     = string
  })
  description = "Configuration parameters for the Cloud Scheduler job."
  default = {
    name        = "event-scheduler-job"
    description = "event-scheduler-job"
    schedule    = "*/5 * * * *"
    payload     = "Mohit !"
  }
}

variable "function_code_bucket_name" {
  type        = string
  description = "Name of the GCS bucket to store the function source code."
  default     = "event-scheduler-trigger-function-code"
}

variable "function_code_source_file" {
  type        = string
  description = "Path to the zipped source code archive."
  default     = "./files/code.zip"
}

variable "function_code_object_name" {
  type        = string
  description = "Object key name for the function ZIP inside the bucket."
  default     = "code.zip"
}

variable "function_config" {
  type = object({
    name         = string
    description  = string
    handler      = string
    runtime      = string
    retry_policy = string
    service = object({
      max_instance_count               = number
      min_instance_count               = number
      available_memory                 = string
      timeout_seconds                  = number
      max_instance_request_concurrency = number
      available_cpu                    = string
      ingress_settings                 = string
      all_traffic_on_latest_revision   = bool
    })
  })
  description = "Build and runtime configurations for the Cloud Run Function."
  default = {
    name         = "event-scheduler-trigger-function"
    description  = "event-scheduler-trigger-function"
    handler      = "helloPubSub"
    runtime      = "nodejs20"
    retry_policy = "RETRY_POLICY_RETRY"
    service = {
      max_instance_count               = 2
      min_instance_count               = 1
      available_memory                 = "4Gi"
      timeout_seconds                  = 60
      max_instance_request_concurrency = 80
      available_cpu                    = "4"
      ingress_settings                 = "ALLOW_INTERNAL_ONLY"
      all_traffic_on_latest_revision   = true
    }
  }
}

variable "propagation_delay" {
  type        = string
  description = "Duration to wait for IAM propagation before creating dependent resources."
  default     = "60s"
}