resource "google_cloud_scheduler_job" "event-scheduler-job" {
  name        = "event-scheduler-job"
  description = "event-scheduler-job"
  schedule    = "*/5 * * * *"
  pubsub_target {
    topic_name = google_pubsub_topic.event-scheduler-topic.id
    data       = base64encode("Mohit !")
  }
}
