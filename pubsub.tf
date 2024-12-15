resource "google_pubsub_topic" "event-scheduler-topic" {
  name = "event-scheduler-topic"
  labels = {
    name = "event-scheduler-topic"
  }
  message_retention_duration = "86600s"
}
