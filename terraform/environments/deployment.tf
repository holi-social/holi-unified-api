/**
 * The resource ids of resources must be unique. Since we might create resources for a branch multiple times
 * (after destroying the ones created before maybe failed, e.g. on environment cleanup, reopening a branch), we ensure uniqueness
 * by appending some random data to resource ids in order to avoid collisions.
 */
resource "random_id" "main" {
  byte_length = 2
  prefix      = "${local.service_name}-${local.environment}-"
}


resource "google_project_service" "service" {
  for_each = toset([
    "run.googleapis.com",
    "servicemanagement.googleapis.com",
    "servicecontrol.googleapis.com",
    "endpoints.googleapis.com",
  ])

  service = each.key

  project = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
  # keep this property as false. Having it true caused https://holi.atlassian.net/wiki/spaces/HOLI/pages/348258312/2023-06-27+All+services+down
  disable_dependent_services = false
  disable_on_destroy         = false
}

# in CI, this is set via scripts/create-or-update-env.sh 
variable "image_tag" {
  type     = string
  nullable = false
}

resource "google_cloud_run_service" "unified_api" {
  project  = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
  name     = random_id.main.hex
  location = local.default_region # finland, low CO2 emissions
  # https://github.com/hashicorp/terraform-provider-google/issues/5898
  autogenerate_revision_name = true

  template {
    spec {
      service_account_name = data.terraform_remote_state.holi_unified_api_common_state.outputs.cloud_run_service_account_email
      containers {
        image = "${data.terraform_remote_state.holi_infra_state.outputs.artifact_registry_location}/holi-unified-api:${var.image_tag}"
        ports {
          container_port = 4455
        }

        env {
          name  = "ENVIRONMENT_ID"
          value = local.environment
        }
        env {
          name  = "OKUNA_URL"
          value = local.okuna_url
        }
        env {
          name  = "OKUNA_DOMAIN"
          value = local.okuna_domain
        }
        env {
          name  = "DONATIONS_API_URL"
          value = local.donations_api_url
        }
        env {
          name  = "GOODNEWS_API_URL"
          value = local.goodnews_api_url
        }
        env {
          name  = "GEO_API_URL"
          value = local.geo_api_url
        }
        env {
          name  = "EVENTS_API_URL"
          value = local.events_api_url
        }
        env {
          name  = "NOTIFICATIONS_API_URL"
          value = local.notifications_api_url
        }
        env {
          name  = "TRANSLATION_API_URL"
          value = local.translation_api_url
        }
        env {
          name  = "TYPESENSE_API_URL"
          value = "https://t9vemwkibxajcorqp-1.a1.typesense.net:443"
        }
        env {
          name = "TYPESENSE_API_KEY"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = local.environment == "production" ? "TYPESENSE_READ_ONLY_API_KEY_PRODUCTION" : "TYPESENSE_READ_ONLY_API_KEY_DEVELOPMENT"
            }
          }
        }
        env {
          name  = "TYPESENSE_COLLECTION"
          value = local.environment == "production" ? "holi_search_production" : "holi_search_staging"
        }
        env {
          name  = "REDIS_HOST"
          value = data.terraform_remote_state.holi_infra_state.outputs.redis_host_cmek_development
        }
        env {
          name  = "REDIS_PORT"
          value = data.terraform_remote_state.holi_infra_state.outputs.redis_port_cmek_development
        }
        env {
          name = "REDIS_PASSWORD"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = "REDIS_CMEK_PASSWORD"
            }
          }
        }
        env {
          name  = "REDIS_DB"
          value = local.environment == "production" ? "13" : "5"
        }
        env {
          name  = "MODERATION_BACKEND_URL"
          value = local.moderation_backend_url
        }

        env {
          name  = "REWARDS_API_URL"
          value = local.rewards_backend_url
        }

        env {
          name  = "MATRIX_SERVER_BASE_URL"
          value = local.environment == "production" ? "https://chat.holi.social" : "https://development-chat.holi.social"
        }
        # switching the ory project to production/development
        env {
          name  = "ACCESS_RULES_REPOSITORIES"
          value = local.environment == "production" ? "file:///opt/oathkeeper/rules-production.yaml" : "file:///opt/oathkeeper/rules-staging.yaml"
        }
        env {
          name  = "MUTATORS_ID_TOKEN_CONFIG_ISSUER_URL"
          value = local.environment == "production" ? "https://auth.holi.social" : "https://dev-auth.holi.social"
        }
        env {
          name  = "AUTHENTICATORS_COOKIE_SESSION_CONFIG_ONLY"
          value = local.environment == "production" ? "ory_session_flamboyanthopperh35qftghn9" : "ory_session_mystifyingcarverakajr6v4t8"
        }
        env {
          name  = "ORY_WHOAMI_URL"
          value = local.environment == "production" ? "https://auth.holi.social/sessions/whoami" : "https://dev-auth.holi.social/sessions/whoami"
        }
        env {
          name  = "ORY_SESSION_KEY"
          value = local.environment == "production" ? "ory_session_flamboyanthopperh35qftghn9" : "ory_session_mystifyingcarverakajr6v4t8"
        }
        env {
          name  = "AUTHENTICATORS_COOKIE_SESSION_CONFIG_CHECK_SESSION_URL"
          value = "http://localhost:4000/orywhoami"
        }
        env {
          name  = "AUTHENTICATORS_BEARER_TOKEN_CONFIG_CHECK_SESSION_URL"
          value = "http://localhost:4000/orywhoami"
        }
        env {
          name  = "VIDEOCALL_URL"
          value = local.environment == "production" ? "https://meet.holi.social" : "https://development.meet.holi.social"
        }
        env {
          name  = "CHALLENGES_URL"
          value = local.environment == "production" ? "https://challenges.holi.social" : "https://staging.challenges-dev.holi.social"
        }
        env {
          name = "NOVU_API_KEY"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = local.environment == "production" ? "NOVU_API_KEY_PRODUCTION" : "NOVU_API_KEY_DEVELOPMENT"
            }
          }
        }
        env {
          name = "NOVU_ENVIRONMENT_ID"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = local.environment == "production" ? "NOVU_ENVIRONMENT_ID_PRODUCTION" : "NOVU_ENVIRONMENT_ID_DEVELOPMENT"
            }
          }
        }
        env {
          name = "JITSI_JWT_SECRET"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = local.environment == "production" ? "JITSI_JWT_SECRET_PRODUCTION" : "JITSI_JWT_SECRET_DEVELOPMENT"
            }
          }
        }
        volume_mounts {
          mount_path = "/opt/oathkeeper/secrets/"
          name       = "JWKS"
        }

        resources {
          limits = {
            # cpu can only be scaled down to 1000m as long as container_concurrency is set to != 1
            cpu    = local.environment == "production" ? "1000m" : "1000m"
            memory = local.environment == "production" ? "512Mi" : "512Mi"
          }
          requests = {
            cpu    = local.environment == "production" ? "1000m" : "1000m"
            memory = local.environment == "production" ? "512Mi" : "512Mi"
          }
        }

        startup_probe {
          period_seconds    = 5
          timeout_seconds   = 5
          failure_threshold = 10
          http_get {
            path = "/health"
          }
        }

        liveness_probe {
          period_seconds    = 15
          timeout_seconds   = 10
          failure_threshold = 3
          http_get {
            path = "/health"
          }
        }
      }
      volumes {
        name = "JWKS"
        secret {
          secret_name = local.environment == "production" ? "ORY_PRIVATE_KEY_PRODUCTION" : "ORY_PRIVATE_KEY_DEVELOPMENT"
          items {
            key  = "latest"
            path = "jwks.json"
          }
        }
      }
      container_concurrency = 0 # 0 means thread safe, no restriction on max concurrency
    }
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"        = local.environment == "production" ? "1" : "0"
        "autoscaling.knative.dev/maxScale"        = local.environment == "production" ? "10" : "2"
        "run.googleapis.com/vpc-access-connector" = data.terraform_remote_state.holi_infra_state.outputs.vpc_access_connector_name
        # possible values: all-traffic/private-ranges-only(default) https://cloud.google.com/sdk/gcloud/reference/run/services/update#--vpc-egress
        # this needs to be set to all-traffic in order to route a cloud run url correctly, since it does resolve to a non-private ip address.
        "run.googleapis.com/vpc-access-egress" = "all-traffic"
        "run.googleapis.com/startup-cpu-boost" = "true"
      }
      # labels set on the revision level
      labels = {
        "environment_type" = local.environment_type
        "holi_service"     = "unified-api"
      }
    }
  }

  metadata {
    # labels set on the service level
    labels = {
      "environment_type" = local.environment_type
      "holi_service"     = "unified-api"
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_project_service.service]
}

resource "google_cloud_run_domain_mapping" "holi_social_unified_api" {
  project = google_cloud_run_service.unified_api.project
  # location needs to be the same as the service's
  location = google_cloud_run_service.unified_api.location
  name     = local.dns_name

  metadata {
    namespace = google_cloud_run_service.unified_api.project
  }

  spec {
    route_name = google_cloud_run_service.unified_api.name
  }
}

data "google_iam_policy" "unified_api" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "unified_api" {
  location = google_cloud_run_service.unified_api.location
  project  = google_cloud_run_service.unified_api.project
  service  = google_cloud_run_service.unified_api.name

  policy_data = data.google_iam_policy.unified_api.policy_data
}
