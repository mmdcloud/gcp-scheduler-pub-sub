resource "google_cloud_scheduler_job" "event-scheduler-job" {
  name        = var.name
  description = var.description
  schedule    = var.schedule
  pubsub_target {
    topic_name = var.pubsub_topic_name
    data       = var.pubsub_data
  }
}
