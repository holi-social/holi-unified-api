resource "google_service_account" "unified_api" {
  project      = data.terraform_remote_state.holi_infra_state.outputs.shared_project_id
  account_id   = "cloudrun-service-unified-api"
  display_name = "Unified API service account for Cloud Run"
}

output "cloud_run_service_account_email" {
  value = google_service_account.unified_api.email
}
