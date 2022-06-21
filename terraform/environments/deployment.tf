/**
 * The resource ids of resources must be unique. Since we might create resources for a branch multiple times
 * (after destroying the ones created before maybe failed, e.g. on environment cleanup, reopening a branch), we ensure uniqueness
 * by appending some random data to resource ids in order to avoid collisions.
 */
resource "random_id" "main" {
  byte_length = 2
  prefix      = "unified-api-${local.environment}-"
}


resource "google_project_service" "service" {
  for_each = toset([
    "run.googleapis.com",
    "servicemanagement.googleapis.com",
    "servicecontrol.googleapis.com",
    "endpoints.googleapis.com",
  ])

  service = each.key

  project            = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
  disable_on_destroy = false
}

# in CI, this is set via scripts/create-or-update-env.sh 
variable "image_tag" {
  type     = string
  nullable = false
}

resource "google_cloud_run_service" "unified_api" {
  project  = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
  name     = random_id.main.hex
  location = "europe-north1" # TODO: Frankfurt doesn't work, settle on a region here (north1 is finland and very co2 friendly)

  template {
    spec {
      containers {
        image = "${data.terraform_remote_state.holi_infra_state.outputs.gcr_location}/holi-unified-api:${var.image_tag}"
        ports {
          container_port = 4455
        }
        env {
          name  = "OKUNA_URL"
          value = local.okuna_url
        }

        resources {
          limits = {
            # cpu can only be scaled down to 1000m as long as container_concurrency is set to != 1
            cpu    = local.environment == "production" ? "1000m" : "1000m"
            memory = local.environment == "production" ? "512Mi" : "256Mi"
          }
          requests = {
            cpu    = local.environment == "production" ? "1000m" : "10m"
            memory = local.environment == "production" ? "512Mi" : "256Mi"
          }
        }
      }
      container_concurrency = 0 # 0 means thread safe, no restriction on max concurrency
    }
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"        = local.environment == "production" ? "0" : "0"
        "autoscaling.knative.dev/maxScale"        = local.environment == "production" ? "10" : "1"
        "run.googleapis.com/vpc-access-connector" = data.terraform_remote_state.holi_infra_state.outputs.vpc_access_connector_name
        # possible values: all-traffic/private-ranges-only(default) https://cloud.google.com/sdk/gcloud/reference/run/services/update#--vpc-egress
        # this needs to be set to all-traffic in order to route a cloud run url correctly, since it does resolve to a non-private ip address.
        "run.googleapis.com/vpc-access-egress"    = "all-traffic"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_project_service.service]
}

resource "google_cloud_run_domain_mapping" "unified_api" {
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
