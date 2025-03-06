# Service Account
module "sa" {
  source       = "./modules/service-account"
  account_id   = "event-scheduler-sa"
  display_name = "event-scheduler-sa"
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
  source                             = "./modules/cloud-run-function"
  function_name                      = "event-scheduler-trigger-function"
  function_description               = "event-scheduler-trigger-function"
  handler                            = "helloPubSub"
  runtime                            = "nodejs20"
  location                           = var.location
  storage_source_bucket              = module.function_code_bucket.bucket_name
  storage_source_bucket_object       = module.function_code_bucket.objects[0].name
  function_app_service_account_email = module.sa.email
  max_instance_count                 = 2
  min_instance_count                 = 1
  available_memory                   = "4Gi"
  timeout_seconds                    = 60
  max_instance_request_concurrency   = 80
  available_cpu                      = "4"
  ingress_settings                   = "ALLOW_INTERNAL_ONLY"
  all_traffic_on_latest_revision     = true

  event_trigger_event_type   = "google.cloud.pubsub.topic.v1.messagePublished"
  event_trigger_topic        = module.pubsub.topic_id
  event_trigger_retry_policy = "RETRY_POLICY_RETRY"
  depends_on                 = [module.sa]
}
