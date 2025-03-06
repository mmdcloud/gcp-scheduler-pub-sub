resource "google_cloudfunctions2_function" "function" {
  name        = var.function_name
  location    = var.location
  description = var.function_description
  build_config {
    runtime     = var.runtime
    entry_point = var.handler
    source {
      storage_source {
        bucket = var.storage_source_bucket
        object = var.storage_source_bucket_object
      }
    }
  }
  service_config {
    max_instance_count             = var.max_instance_count
    min_instance_count             = var.min_instance_count
    max_instance_request_concurrency = var.max_instance_request_concurrency
    available_memory               = var.available_memory
    available_cpu = var.available_cpu
    timeout_seconds                = var.timeout_seconds
    ingress_settings               = var.ingress_settings
    all_traffic_on_latest_revision = var.all_traffic_on_latest_revision
    service_account_email          = var.function_app_service_account_email
  }
  event_trigger {
    event_type            = var.event_trigger_event_type
    pubsub_topic          = var.event_trigger_topic
    retry_policy          = var.event_trigger_retry_policy
  }
}
