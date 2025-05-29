# Service Account
data "google_compute_default_service_account" "default_sa" {}

resource "google_project_iam_member" "default_sa_permissions" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/storage.objectViewer",
    "roles/artifactregistry.writer"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${data.google_compute_default_service_account.default_sa.email}"
}

resource "time_sleep" "wait_60_seconds" {
  create_duration = "60s"
  # depends_on      = [module.some_module]
}


# PubSub
module "pubsub" {
  source                     = "./modules/pubsub"
  name                       = "event-scheduler-topic"
  message_retention_duration = "86600s"
}

# Scheduler 
module "scheduler" {
  source            = "./modules/scheduler"
  name              = "event-scheduler-job"
  description       = "event-scheduler-job"
  schedule          = "*/5 * * * *"
  pubsub_topic_name = module.pubsub.topic_id
  pubsub_data       = base64encode("Mohit !")
}

# Source Code Bucker
module "function_code_bucket" {
  source                      = "./modules/gcs"
  bucket_name                 = "event-scheduler-trigger-function-code"
  location                    = var.location
  uniform_bucket_level_access = true
  objects = [
    {
      name   = "code.zip"
      source = "./files/code.zip"
    }
  ]
}

# Cloud Run Function (Any cloud run function can only have one trigger at a time)
module "event_scheduler_trigger_function" {
  source                           = "./modules/cloud-run-function"
  function_name                    = "event-scheduler-trigger-function"
  function_description             = "event-scheduler-trigger-function"
  handler                          = "helloPubSub"
  runtime                          = "nodejs20"
  location                         = var.location
  storage_source_bucket            = module.function_code_bucket.bucket_name
  storage_source_bucket_object     = module.function_code_bucket.objects[0].name
  max_instance_count               = 2
  min_instance_count               = 1
  available_memory                 = "4Gi"
  timeout_seconds                  = 60
  max_instance_request_concurrency = 80
  available_cpu                    = "4"
  ingress_settings                 = "ALLOW_INTERNAL_ONLY"
  all_traffic_on_latest_revision   = true

  event_trigger_event_type   = "google.cloud.pubsub.topic.v1.messagePublished"
  event_trigger_topic        = module.pubsub.topic_id
  event_trigger_retry_policy = "RETRY_POLICY_RETRY"
  depends_on                 = [time_sleep.wait_60_seconds]
}
