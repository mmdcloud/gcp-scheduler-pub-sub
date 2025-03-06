resource "google_pubsub_topic" "event-scheduler-topic" {
  name = "event-scheduler-topic"
  message_retention_duration = "86600s"
  labels = {
    name = "event-scheduler-topic"
  }  
}
