terraform {
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

data "terraform_remote_state" "holi_volunteering_api_common_state" {
  backend = "gcs"
  config = {
    bucket = "holi-shared-terraform-state"
    prefix = "volunteering-api-common"
  }
}

data "terraform_remote_state" "holi_notifications_api_common_state" {
  backend = "gcs"
  config = {
    bucket = "holi-shared-terraform-state"
    prefix = "notifications-api-common"
  }
}

data "terraform_remote_state" "holi_tracking_endpoint_common_state" {
  backend = "gcs"
  config = {
    bucket = "holi-shared-terraform-state"
    prefix = "tracking-endpoint-common"
  }
}

# provider google including beta features
provider "google" {
  region = "europe-north1"
}

provider "google-beta" {
  region = "europe-north1"
}
