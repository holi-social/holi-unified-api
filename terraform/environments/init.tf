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

# provider google including beta features
provider "google" {
  region = "europe-west3"
}

provider "google-beta" {
  region = "europe-west3"
}
