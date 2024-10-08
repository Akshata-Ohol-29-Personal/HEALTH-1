data "google_secret_manager_secret" "oban_key_fingerprint" {
  secret_id = "OBAN_KEY_FINGERPRINT"
}

resource "google_secret_manager_secret_iam_member" "cloud_run_oban_key_fingerprint_access" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.datahub_cloud_run.email}"
  secret_id = data.google_secret_manager_secret.oban_key_fingerprint.id
}

data "google_secret_manager_secret" "oban_license_key" {
  secret_id = "OBAN_LICENSE_KEY"
}

resource "google_secret_manager_secret_iam_member" "cloud_run_oban_license_key_access" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.datahub_cloud_run.email}"
  secret_id = data.google_secret_manager_secret.oban_license_key.id
}

data "google_secret_manager_secret" "datahub_cloak_key" {
  secret_id = "DATAHUB_CLOAK_KEY"
}

resource "google_secret_manager_secret_iam_member" "cloud_run_datahub_cloak_key_access" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.datahub_cloud_run.email}"
  secret_id = data.google_secret_manager_secret.datahub_cloak_key.id
}

data "google_secret_manager_secret" "datahub_metrics_auth_token" {
  secret_id = "DATAHUB_METRICS_AUTH_TOKEN"
}

resource "google_secret_manager_secret_iam_member" "cloud_run_datahub_metrics_auth_token_access" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.datahub_cloud_run.email}"
  secret_id = data.google_secret_manager_secret.datahub_metrics_auth_token.id
}

data "google_secret_manager_secret" "datahub_smtp_password" {
  secret_id = "DATAHUB_SMTP_PASSWORD"
}

resource "google_secret_manager_secret_iam_member" "cloud_run_datahub_smtp_password_access" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.datahub_cloud_run.email}"
  secret_id = data.google_secret_manager_secret.datahub_smtp_password.id
}

data "google_secret_manager_secret" "secret_key_base" {
  secret_id = "SECRET_KEY_BASE"
}

resource "google_secret_manager_secret_iam_member" "cloud_run_secret_key_base_access" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.datahub_cloud_run.email}"
  secret_id = data.google_secret_manager_secret.secret_key_base.id
}

data "google_secret_manager_secret" "tailscale_auth_key" {
  secret_id = "TAILSCALE_AUTH_KEY"
}

resource "google_secret_manager_secret_iam_member" "cloud_run_tailscale_auth_key_access" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.datahub_cloud_run.email}"
  secret_id = data.google_secret_manager_secret.tailscale_auth_key.id
}

data "google_secret_manager_secret" "google_oauth_client_id" {
  secret_id = "GOOGLE_OAUTH_CLIENT_ID"
}

resource "google_secret_manager_secret_iam_member" "cloud_run_google_oauth_client_id_access" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.datahub_cloud_run.email}"
  secret_id = data.google_secret_manager_secret.google_oauth_client_id.id
}

data "google_secret_manager_secret" "google_oauth_client_secret" {
  secret_id = "GOOGLE_OAUTH_CLIENT_SECRET"
}

resource "google_secret_manager_secret_iam_member" "cloud_run_google_oauth_client_secret_access" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.datahub_cloud_run.email}"
  secret_id = data.google_secret_manager_secret.google_oauth_client_secret.id
}

data "google_secret_manager_secret" "google_cloud_sql_ca_cert" {
  secret_id = "GOOGLE_CLOUD_SQL_CA_CERT"
}

resource "google_secret_manager_secret_iam_member" "cloud_run_google_cloud_sql_ca_cert_access" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.datahub_cloud_run.email}"
  secret_id = data.google_secret_manager_secret.google_cloud_sql_ca_cert.id
}

data "google_secret_manager_secret" "google_cloud_sql_cert" {
  secret_id = "GOOGLE_CLOUD_SQL_CERT"
}

resource "google_secret_manager_secret_iam_member" "cloud_run_google_cloud_sql_cert_access" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.datahub_cloud_run.email}"
  secret_id = data.google_secret_manager_secret.google_cloud_sql_cert.id
}

data "google_secret_manager_secret" "google_cloud_sql_privkey" {
  secret_id = "GOOGLE_CLOUD_SQL_PRIVKEY"
}

resource "google_secret_manager_secret_iam_member" "cloud_run_google_cloud_sql_privkey_access" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.datahub_cloud_run.email}"
  secret_id = data.google_secret_manager_secret.google_cloud_sql_privkey.id
}
