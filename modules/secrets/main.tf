# -- OBAN_KEY_FINGERPRINT

data "local_file" "oban_key_fingerprint" {
  filename = "../../../secrets/oban_key_fingerprint"
}

resource "google_secret_manager_secret" "oban_key_fingerprint" {
  secret_id = "OBAN_KEY_FINGERPRINT"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "oban_key_fingerprint" {
  secret      = google_secret_manager_secret.oban_key_fingerprint.id
  secret_data = data.local_file.oban_key_fingerprint.content
}

# -- OBAN_LICENSE_KEY

data "local_file" "oban_license_key" {
  filename = "../../../secrets/oban_license_key"
}

resource "google_secret_manager_secret" "oban_license_key" {
  secret_id = "OBAN_LICENSE_KEY"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "oban_license_key" {
  secret      = google_secret_manager_secret.oban_license_key.id
  secret_data = data.local_file.oban_license_key.content
}

# -- DATAHUB_CLOAK_KEY

data "local_file" "datahub_cloak_key" {
  filename = "../../../secrets/datahub_cloak_key"
}

resource "google_secret_manager_secret" "datahub_cloak_key" {
  secret_id = "DATAHUB_CLOAK_KEY"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "datahub_cloak_key" {
  secret      = google_secret_manager_secret.datahub_cloak_key.id
  secret_data = data.local_file.datahub_cloak_key.content
}

# -- DATAHUB_METRICS_AUTH_TOKEN

data "local_file" "datahub_metrics_auth_token" {
  filename = "../../../secrets/datahub_metrics_auth_token"
}

resource "google_secret_manager_secret" "datahub_metrics_auth_token" {
  secret_id = "DATAHUB_METRICS_AUTH_TOKEN"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "datahub_metrics_auth_token" {
  secret      = google_secret_manager_secret.datahub_metrics_auth_token.id
  secret_data = data.local_file.datahub_metrics_auth_token.content
}

# -- DATAHUB_SMTP_PASSWORD

data "local_file" "datahub_smtp_password" {
  filename = "../../../secrets/datahub_smtp_password"
}

resource "google_secret_manager_secret" "datahub_smtp_password" {
  secret_id = "DATAHUB_SMTP_PASSWORD"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "datahub_smtp_password" {
  secret      = google_secret_manager_secret.datahub_smtp_password.id
  secret_data = data.local_file.datahub_smtp_password.content
}

# -- SECRET_KEY_BASE

data "local_file" "secret_key_base" {
  filename = "../../../secrets/secret_key_base"
}

resource "google_secret_manager_secret" "secret_key_base" {
  secret_id = "SECRET_KEY_BASE"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "secret_key_base" {
  secret      = google_secret_manager_secret.secret_key_base.id
  secret_data = data.local_file.secret_key_base.content
}

# -- TAILSCALE_AUTH_KEY

data "local_file" "tailscale_auth_key" {
  filename = "../../../secrets/tailscale_auth_key"
}

resource "google_secret_manager_secret" "tailscale_auth_key" {
  secret_id = "TAILSCALE_AUTH_KEY"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "tailscale_auth_key" {
  secret      = google_secret_manager_secret.tailscale_auth_key.id
  secret_data = data.local_file.tailscale_auth_key.content
}

# -- GOOGLE_OAUTH_CLIENT_ID

data "local_file" "google_oauth_client_id" {
  filename = "../../../secrets/google_oauth_client_id"
}

resource "google_secret_manager_secret" "google_oauth_client_id" {
  secret_id = "GOOGLE_OAUTH_CLIENT_ID"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "google_oauth_client_id" {
  secret      = google_secret_manager_secret.google_oauth_client_id.id
  secret_data = data.local_file.google_oauth_client_id.content
}

# -- GOOGLE_OAUTH_CLIENT_SECRET

data "local_file" "google_oauth_client_secret" {
  filename = "../../../secrets/google_oauth_client_secret"
}

resource "google_secret_manager_secret" "google_oauth_client_secret" {
  secret_id = "GOOGLE_OAUTH_CLIENT_SECRET"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "google_oauth_client_secret" {
  secret      = google_secret_manager_secret.google_oauth_client_secret.id
  secret_data = data.local_file.google_oauth_client_secret.content
}

# -- GOOGLE_CLOUD_SQL_CA_CERT

data "local_file" "google_cloud_sql_ca_cert" {
  filename = "../../../secrets/google_cloud_sql_ca_cert"
}

resource "google_secret_manager_secret" "google_cloud_sql_ca_cert" {
  secret_id = "GOOGLE_CLOUD_SQL_CA_CERT"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "google_cloud_sql_ca_cert" {
  secret      = google_secret_manager_secret.google_cloud_sql_ca_cert.id
  secret_data = data.local_file.google_cloud_sql_ca_cert.content
}

# -- GOOGLE_CLOUD_SQL_CERT

data "local_file" "google_cloud_sql_cert" {
  filename = "../../../secrets/google_cloud_sql_cert"
}

resource "google_secret_manager_secret" "google_cloud_sql_cert" {
  secret_id = "GOOGLE_CLOUD_SQL_CERT"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "google_cloud_sql_cert" {
  secret      = google_secret_manager_secret.google_cloud_sql_cert.id
  secret_data = data.local_file.google_cloud_sql_cert.content
}

# -- GOOGLE_CLOUD_SQL_PRIVKEY

data "local_file" "google_cloud_sql_privkey" {
  filename = "../../../secrets/google_cloud_sql_privkey"
}

resource "google_secret_manager_secret" "google_cloud_sql_privkey" {
  secret_id = "GOOGLE_CLOUD_SQL_PRIVKEY"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "google_cloud_sql_privkey" {
  secret      = google_secret_manager_secret.google_cloud_sql_privkey.id
  secret_data = data.local_file.google_cloud_sql_privkey.content
}

# -- SFTP_SSH_HOST_ED25519_KEY

data "local_file" "sftp_ssh_host_ed25519_key" {
  filename = "../../../secrets/sftp_ssh_host_ed25519_key"
}

resource "google_secret_manager_secret" "sftp_ssh_host_ed25519_key" {
  secret_id = "SFTP_SSH_HOST_ED25519_KEY"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "sftp_ssh_host_ed25519_key" {
  secret      = google_secret_manager_secret.sftp_ssh_host_ed25519_key.id
  secret_data = data.local_file.sftp_ssh_host_ed25519_key.content
}

# -- SFTP_SSH_HOST_RSA_KEY

data "local_file" "sftp_ssh_host_rsa_key" {
  filename = "../../../secrets/sftp_ssh_host_rsa_key"
}

resource "google_secret_manager_secret" "sftp_ssh_host_rsa_key" {
  secret_id = "SFTP_SSH_HOST_RSA_KEY"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "sftp_ssh_host_rsa_key" {
  secret      = google_secret_manager_secret.sftp_ssh_host_rsa_key.id
  secret_data = data.local_file.sftp_ssh_host_rsa_key.content
}

# -- SFTP_USERS

data "local_file" "sftp_users" {
  filename = "../../../secrets/sftp_users"
}

resource "google_secret_manager_secret" "sftp_users" {
  secret_id = "SFTP_USERS"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "sftp_users" {
  secret      = google_secret_manager_secret.sftp_users.id
  secret_data = data.local_file.sftp_users.content
}
