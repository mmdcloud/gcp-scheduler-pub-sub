variable "name" {
  type = string
}
variable "description" {
  type    = string
  default = ""
}
variable "schedule" {
  type    = string
  default = ""
}
variable "time_zone" {
  type    = string
  default = ""
}
variable "region" {
  type    = string
  default = ""
}
variable "attempt_deadline" {
  type    = string
  default = ""
}

variable "app_engine_http_target" {
  type = object({
    body         = optional(string)
    headers      = optional(map(string))
    http_method  = optional(string)
    relative_uri = string
  })
  default = null
}

variable "pubsub_target" {
  type = object({
    attributes = optional(map(string))
    topic_name = string
    data       = optional(string)
  })
  default = null
}

variable "retry_config" {
  type = object({
    max_backoff_duration = optional(string)
    max_doublings        = optional(number)
    max_retry_duration   = optional(string)
    min_backoff_duration = optional(string)
    retry_count          = optional(number)
  })
  default = null
}

variable "http_target" {
  type = object({
    body        = optional(string)
    headers     = optional(map(string))
    http_method = optional(string)
    uri         = string
    oauth_token = object({
      scope                 = optional(string)
      service_account_email = string
    })
    oidc_token = object({
      audience              = optional(string)
      service_account_email = string
    })
  })
  default = null
}