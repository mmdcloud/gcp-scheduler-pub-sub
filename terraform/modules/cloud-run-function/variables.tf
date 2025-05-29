
variable "location" {}
variable "function_name" {}
variable "function_description" {}
variable "runtime" {}
variable "handler" {}

variable "ingress_settings" {}
variable "all_traffic_on_latest_revision" {}
# variable "function_app_service_account_email" {}
variable "max_instance_count" {}
variable "min_instance_count" {}
variable "available_memory" {}
variable "available_cpu" {}
variable "timeout_seconds" {}
variable "max_instance_request_concurrency" {}

variable "storage_source_bucket" {}
variable "storage_source_bucket_object" {}

variable "event_trigger_event_type" {}
variable "event_trigger_topic" {}
variable "event_trigger_retry_policy" {}
