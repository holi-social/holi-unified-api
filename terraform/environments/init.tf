terraform {
  # allow the lowest common version across all projects, so that the current CI docker image version suits all projects
  required_version = ">= 1.9"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.25.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "6.25.0"
    }
  }
  backend "gcs" {
    bucket = "holi-shared-terraform-state"
    prefix = "unified-api-environments"
  }
}

data "terraform_remote_state" "holi_infra_state" {
  backend = "gcs"
  config = {
    bucket = "holi-shared-terraform-state"
    prefix = "infra"
  }
}

data "terraform_remote_state" "holi_unified_api_common_state" {
  backend = "gcs"
  config = {
    bucket = "holi-shared-terraform-state"
    prefix = "unified-api-common"
  }
}

data "terraform_remote_state" "holi_okuna_common_state" {
  backend = "gcs"
  config = {
    bucket = "holi-shared-terraform-state"
    prefix = "okuna-common"
  }
}

data "terraform_remote_state" "holi_donations_api_common_state" {
  backend = "gcs"
  config = {
    bucket = "holi-shared-terraform-state"
    prefix = "donations-api-common"
  }
}

data "terraform_remote_state" "holi_goodnews_api_common_state" {
  backend = "gcs"
  config = {
    bucket = "holi-shared-terraform-state"
    prefix = "goodnews-api-common"
  }
}

data "terraform_remote_state" "holi_geo_api_common_state" {
  backend = "gcs"
  config = {
    bucket = "holi-shared-terraform-state"
    prefix = "geo-api-common"
  }
}

data "terraform_remote_state" "holi_events_common_state" {
  backend = "gcs"
  config = {
    bucket = "holi-shared-terraform-state"
    prefix = "events-common"
  }
}

data "terraform_remote_state" "holi_notifications_api_common_state" {
  backend = "gcs"
  config = {
    bucket = "holi-shared-terraform-state"
    prefix = "notifications-api-common"
  }
}

data "terraform_remote_state" "holi_translation_api_common_state" {
  backend = "gcs"
  config = {
    bucket = "holi-shared-terraform-state"
    prefix = "translation-api-common"
  }
}

data "terraform_remote_state" "holi_moderation_environment_state" {
  backend = "gcs"
  # provide staging moderation environment state for all review deployments of unified-api
  workspace = local.environment == "production" ? "production" : "staging"
  config = {
    bucket = "holi-shared-terraform-state"
    prefix = "moderation-environments"
  }
}

data "terraform_remote_state" "rewards" {
  backend   = "gcs"
  workspace = local.environment == "production" ? "production" : "staging"
  config = {
    bucket = "holi-shared-terraform-state"
    prefix = "rewards-environments"
  }
}

# provider google including beta features
provider "google" {
  region = local.default_region
}

provider "google-beta" {
  region = local.default_region
}
