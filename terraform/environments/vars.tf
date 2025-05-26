locals {
  # predefined environment names are staging, production, and for any branch, its gitlab <CI_ENVIRONMENT_SLUG>
  environment      = terraform.workspace
  environment_name = trim(substr(local.environment, 0, 22), ".-") # limits the length of the name that it fits constraints google imposes for some resources, e.g. project ids
  environment_type = contains(["staging", "production"], local.environment) ? local.environment : "review"

  service_name = "unified-api"
  # the dns name can be at most 64 chars in total. The environment passed in via gitlab is max 24 chars (CI_ENVIRONMENT_SLUG).
  dns_name = "${local.environment}.${data.terraform_remote_state.holi_unified_api_common_state.outputs.dns_unified_api_domain}"

  api_domain       = trimsuffix(google_dns_record_set.holi_social_unified_api_domain_record_set.name, ".")
  api_endpoint_url = "https://${local.api_domain}/graphql"

  okuna_domain           = "https://${local.environment == "production" ? "production" : "staging"}.${data.terraform_remote_state.holi_okuna_common_state.outputs.dns_okuna_domain}"
  okuna_url              = "https://${local.environment == "production" ? "production" : "staging"}.${data.terraform_remote_state.holi_okuna_common_state.outputs.dns_okuna_domain}/graphql"
  donations_api_url      = "https://${local.environment == "production" ? "production" : "staging"}.${data.terraform_remote_state.holi_donations_api_common_state.outputs.dns_donations_api_domain}/graphql"
  goodnews_api_url       = "https://${local.environment == "production" ? "production" : "staging"}.${data.terraform_remote_state.holi_goodnews_api_common_state.outputs.dns_goodnews_api_domain}/graphql"
  geo_api_url            = "https://${local.environment == "production" ? "production" : "staging"}.${data.terraform_remote_state.holi_geo_api_common_state.outputs.dns_geo_api_domain}/graphql"
  volunteering_api_url   = "https://${local.environment == "production" ? "production" : "staging"}.${data.terraform_remote_state.holi_volunteering_api_common_state.outputs.dns_volunteering_api_domain}/graphql"
  events_api_url         = "https://${local.environment == "production" ? "production" : "staging"}.${data.terraform_remote_state.holi_events_common_state.outputs.dns_events_domain}/graphql"
  notifications_api_url  = "https://${local.environment == "production" ? "production" : "staging"}.${data.terraform_remote_state.holi_notifications_api_common_state.outputs.dns_notifications_api_domain}/graphql"
  translation_api_url    = "https://${local.environment == "production" ? "production" : "staging"}.${data.terraform_remote_state.holi_translation_api_common_state.outputs.dns_translation_api_domain}/graphql"
  moderation_backend_url = "https://${data.terraform_remote_state.holi_moderation_environment_state.outputs.backend_domain}/graphql"
  typesense_api_url      = "https://${local.environment == "production" ? "search" : "dev-search"}.holi.social:433"
  typesense_api_key      = local.environment == "production" ? "jtOdwRfhEFW7UmCpDKjnQaS71uU28YOq" : "WAxFP8Gv9RrNvG18RhYgXCNNj39LfAu2"
  typesense_collection   = local.environment == "production" ? "holi_search_production" : "holi_search_staging"
  default_region         = data.terraform_remote_state.holi_infra_state.outputs.default_region
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

output "events_api_url" {
  value = local.events_api_url
}

output "notifications_api_url" {
  value = local.notifications_api_url
}

output "translation_api_url" {
  value = local.translation_api_url
}

output "moderation_backend_url" {
  value = local.moderation_backend_url
}

output "typesense_api_url" {
  value = local.typesense_api_url
}

output "typesense_api_key" {
  value = local.typesense_api_key
}

output "typesense_collection" {
  value = local.typesense_collection
}

output "api_domain" {
  value       = local.api_domain
  description = "Domain under which the unified API runs"
}

output "api_endpoint_url" {
  value       = local.api_endpoint_url
  description = "GraphQL API endpoint URL of the unified API"
}
