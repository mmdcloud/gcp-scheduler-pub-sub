resource "google_cloud_scheduler_job" "event-scheduler-job" {
  name             = var.name
  description      = var.description
  schedule         = var.schedule
  time_zone        = var.time_zone
  region           = var.region
  attempt_deadline = var.attempt_deadline

  dynamic "app_engine_http_target" {
    for_each = var.app_engine_http_target != null ? [var.app_engine_http_target] : []
    content {
      body         = app_engine_http_target.value.body
      headers      = app_engine_http_target.value.headers
      http_method  = app_engine_http_target.value.http_method
      relative_uri = app_engine_http_target.value.relative_uri
    }
  }

  dynamic "http_target" {
    for_each = var.app_engine_http_target != null ? [var.app_engine_http_target] : []
    content {
      body        = http_target.value.body
      headers     = http_target.value.headers
      http_method = http_target.value.http_method
      uri         = http_target.value.uri

      dynamic "oauth_token" {
        for_each = http_target.value.oauth_token != null ? [http_target.value.oauth_token] : []
        content {
          scope                 = oauth_token.value.scope
          service_account_email = oauth_token.value.service_account_email
        }
      }

      dynamic "oidc_token" {
        for_each = http_target.value.oidc_token != null ? [http_target.value.oidc_token] : []
        content {
          audience              = oidc_token.value.audience
          service_account_email = oauth_token.value.service_account_email
        }
      }
    }
  }

  dynamic "retry_config" {
    for_each = var.retry_config != null ? [var.retry_config] : []
    content {
      max_backoff_duration = retry_config.value.max_backoff_duration
      max_doublings        = retry_config.value.max_doublings
      max_retry_duration   = retry_config.value.max_retry_duration
      min_backoff_duration = retry_config.value.min_backoff_duration
      retry_count          = retry_config.value.retry_count
    }
  }

  dynamic "pubsub_target" {
    for_each = var.pubsub_target != null ? [var.pubsub_target] : []
    content {
      attributes = pubsub_target.value.attributes
      topic_name = pubsub_target.value.topic_name
      data       = pubsub_target.value.data
    }
  }
}