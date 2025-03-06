resource "google_service_account" "event-scheduler-service-account" {
  account_id   = "event-scheduler-sa"
  display_name = "event-scheduler-sa"
}
resource "google_storage_bucket" "event-scheduler-trigger-function-code-bucket" {
  name                        = "event-scheduler-trigger-function-code"
  location                    = var.location
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "event-scheduler-trigger-function-code-object" {
  name   = "code.zip"
  bucket = google_storage_bucket.event-scheduler-trigger-function-code-bucket.name
  source = "./files/code.zip"
}

resource "google_cloudfunctions2_function" "event-scheduler-trigger-function" {
  name        = "event-scheduler-trigger-function"
  location    = var.location
  description = "event-scheduler-trigger-function"

  build_config {
    runtime     = "nodejs20"
    entry_point = "helloPubSub"
    environment_variables = {
      BUILD_CONFIG_TEST = "build_test"
    }
    source {
      storage_source {
        bucket = google_storage_bucket.event-scheduler-trigger-function-code-bucket.name
        object = google_storage_bucket_object.event-scheduler-trigger-function-code-object.name
      }
    }
  }

  service_config {
    environment_variables = {
      SERVICE_CONFIG_TEST      = "config_test"
      SERVICE_CONFIG_DIFF_TEST = google_service_account.event-scheduler-service-account.email
    }
    max_instance_count               = 2
    min_instance_count               = 1
    available_memory                 = "4Gi"
    timeout_seconds                  = 60
    max_instance_request_concurrency = 80
    available_cpu                    = "4"
    
    ingress_settings               = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true
    service_account_email          = google_service_account.event-scheduler-service-account.email
  }

  event_trigger {
    trigger_region = var.location
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.event-scheduler-topic.id
    retry_policy   = "RETRY_POLICY_RETRY"
  }
}
