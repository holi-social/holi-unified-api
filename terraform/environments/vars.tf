locals {
  # predefined environment names are staging, production, and for any branch, its gitlab <CI_ENVIRONMENT_SLUG>
  environment = terraform.workspace
  # the dns name can be at most 64 chars in total. The environment passed in via gitlab is max 24 chars (CI_ENVIRONMENT_SLUG).
  dns_name = "${local.environment}.${data.terraform_remote_state.holi_unified_api_common_state.outputs.dns_unified_api_domain}"
  # in staging and production envs, we are deploying the docker image built from the main branch
  docker_image_tag = contains(["staging", "production"], local.environment) ? "main" : local.environment
}
