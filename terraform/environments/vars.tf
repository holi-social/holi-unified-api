locals {
  # predefined environment names are staging, production, and for any branch, its gitlab <CI_ENVIRONMENT_SLUG>
  environment  = terraform.workspace
  service_name = "unified-api"
  # the dns name can be at most 64 chars in total. The environment passed in via gitlab is max 24 chars (CI_ENVIRONMENT_SLUG).
  dns_name = "${local.environment}.${data.terraform_remote_state.holi_unified_api_common_state.outputs.dns_unified_api_domain}"

  okuna_domain         = "https://${local.environment == "production" ? "production" : "staging"}.${data.terraform_remote_state.holi_okuna_common_state.outputs.dns_okuna_domain}"
  okuna_url            = "https://${local.environment == "production" ? "production" : "staging"}.${data.terraform_remote_state.holi_okuna_common_state.outputs.dns_okuna_domain}/graphql"
  donations_api_url    = "https://${local.environment == "production" ? "production" : "staging"}.${data.terraform_remote_state.holi_donations_api_common_state.outputs.dns_donations_api_domain}/graphql"
  goodnews_api_url     = "https://${local.environment == "production" ? "production" : "staging"}.${data.terraform_remote_state.holi_goodnews_api_common_state.outputs.dns_goodnews_api_domain}/graphql"
  geo_api_url          = "https://${local.environment == "production" ? "production" : "staging"}.${data.terraform_remote_state.holi_geo_api_common_state.outputs.dns_geo_api_domain}/graphql"
  volunteering_api_url = "https://${local.environment == "production" ? "production" : "staging"}.${data.terraform_remote_state.holi_volunteering_api_common_state.outputs.dns_volunteering_api_domain}/graphql"
}

output "okuna_domain" {
  value = local.okuna_domain
}

output "okuna_url" {
  value = local.okuna_url
}

output "donations_api_url" {
  value = local.donations_api_url
}

output "goodnews_api_url" {
  value = local.goodnews_api_url
}

output "geo_api_url" {
  value = local.geo_api_url
}

output "volunteering_api_url" {
  value = local.volunteering_api_url
}
