resource "google_service_account" "unified_api" {
  project  = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
  account_id   = "unified-api"
  display_name = "Unified API service account"
}

output "cloud_run_service_account_email" {
  value = google_service_account.unified_api.email
}
