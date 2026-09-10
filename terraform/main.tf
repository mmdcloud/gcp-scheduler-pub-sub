# Service Account Data Source
data "google_compute_default_service_account" "default_sa" {}

# IAM Role Assignments
resource "google_project_iam_member" "default_sa_permissions" {
  for_each = toset(var.iam_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${data.google_compute_default_service_account.default_sa.email}"
}

# IAM Propagation Wait Timer
resource "time_sleep" "wait_for_iam" {
  create_duration = var.propagation_delay

  depends_on = [google_project_iam_member.default_sa_permissions]
}

# PubSub Module
module "pubsub" {
  source                     = "./modules/pubsub"
  topic_name                 = var.pubsub_config.topic_name
  message_retention_duration = var.pubsub_config.message_retention_duration
}

# Scheduler Module
module "scheduler" {
  source      = "./modules/scheduler"
  name        = var.scheduler_config.name
  description = var.scheduler_config.description
  schedule    = var.scheduler_config.schedule

  pubsub_target = {
    topic_name = module.pubsub.topic_id
    data       = base64encode(var.scheduler_config.payload)
  }
}

# Source Code Storage Bucket
module "function_code_bucket" {
  source                      = "./modules/gcs"
  bucket_name                 = var.function_code_bucket_name
  location                    = var.location
  uniform_bucket_level_access = true

  objects = [
    {
      name   = var.function_code_object_name
      source = var.function_code_source_file
    }
  ]
}

# Cloud Run Function
module "event_scheduler_trigger_function" {
  source               = "./modules/cloud-run-function"
  project_id           = var.project_id
  function_name        = var.function_config.name
  function_description = var.function_config.description
  location             = var.location

  build_config = {
    handler = var.function_config.handler
    runtime = var.function_config.runtime
    storage_source = {
      bucket = module.function_code_bucket.bucket_name
      object = module.function_code_bucket.objects[0].name
    }
  }

  service_config = {
    max_instance_count               = var.function_config.service.max_instance_count
    min_instance_count               = var.function_config.service.min_instance_count
    available_memory                 = var.function_config.service.available_memory
    timeout_seconds                  = var.function_config.service.timeout_seconds
    max_instance_request_concurrency = var.function_config.service.max_instance_request_concurrency
    available_cpu                    = var.function_config.service.available_cpu
    ingress_settings                 = var.function_config.service.ingress_settings
    all_traffic_on_latest_revision   = var.function_config.service.all_traffic_on_latest_revision
  }

  event_trigger = {
    event_type   = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic = module.pubsub.topic_id
    retry_policy = var.function_config.retry_policy
  }

  depends_on = [time_sleep.wait_for_iam]
}