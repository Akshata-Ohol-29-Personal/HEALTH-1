JSON_PARSER := $(shell which jq)

.PHONY: secrets clean_secrets \
	clean_cloud_run_secrets clean_secrets_module \
	clean_cloud_sql_secrets cloud_sql_secrets \
	load_secrets \
	pr_qa pr_uat pr_prod

default:
	@echo "safety: must call a specific target" >&2
	@exit 1

secrets: \
	clean_secrets \
	secrets/oban_key_fingerprint \
	secrets/oban_license_key \
	secrets/secret_key_base \
	secrets/datahub_cloak_key \
	secrets/datahub_metrics_auth_token \
	secrets/datahub_smtp_password \
	secrets/tailscale_auth_key \
	secrets/google_oauth_client_id \
	secrets/google_oauth_client_secret \
	secrets/sftp_ssh_host_ed25519_key \
	secrets/sftp_ssh_host_rsa_key

clean_secrets:
	@rm -f \
		secrets/oban_key_fingerprint \
		secrets/oban_license_key \
		secrets/secret_key_base \
		secrets/datahub_cloak_key \
		secrets/datahub_metrics_auth_token \
		secrets/datahub_smtp_password \
		secrets/tailscale_auth_key \
		secrets/google_oauth_client_id \
		secrets/google_oauth_client_secret \
		secrets/sftp_ssh_host_ed25519_key \
		secrets/sftp_ssh_host_rsa_key

ifdef OBAN_KEY_FINGERPRINT
secrets/oban_key_fingerprint:
	@printf "%s" "${OBAN_KEY_FINGERPRINT}" > secrets/oban_key_fingerprint
else
secrets/oban_key_fingerprint:
	@echo "OBAN_KEY_FINGERPRINT not defined, please set in env or on command line" >&2
	exit 1
endif

ifdef OBAN_LICENSE_KEY
secrets/oban_license_key:
	@printf "%s" "${OBAN_LICENSE_KEY}" > secrets/oban_license_key
else
secrets/oban_license_key:
	@echo "OBAN_LICENSE_KEY not defined, please set in env or on command line" >&2
	exit 1
endif

ifdef SECRET_KEY_BASE
secrets/secret_key_base:
	@printf "%s" "${SECRET_KEY_BASE}" > secrets/secret_key_base
else
secrets/secret_key_base:
	@echo "SECRET_KEY_BASE not defined, please set in env or on command line" >&2
	exit 1
endif

ifdef DATAHUB_CLOAK_KEY
secrets/datahub_cloak_key:
	@printf "%s" "${DATAHUB_CLOAK_KEY}" > secrets/datahub_cloak_key
else
secrets/datahub_cloak_key:
	@echo "DATAHUB_CLOAK_KEY not defined, please set in env or on command line" >&2
	exit 1
endif

ifdef DATAHUB_METRICS_AUTH_TOKEN
secrets/datahub_metrics_auth_token:
	@printf "%s" "${DATAHUB_METRICS_AUTH_TOKEN}" > secrets/datahub_metrics_auth_token
else
secrets/datahub_metrics_auth_token:
	@echo "DATAHUB_METRICS_AUTH_TOKEN not defined, please set in env or on command line" >&2
	exit 1
endif

ifdef DATAHUB_SMTP_PASSWORD
secrets/datahub_smtp_password:
	@printf "%s" "${DATAHUB_SMTP_PASSWORD}" > secrets/datahub_smtp_password
else
secrets/datahub_smtp_password:
	@echo "DATAHUB_SMTP_PASSWORD not defined, please set in env or on command line" >&2
	exit 1
endif

ifdef TAILSCALE_AUTH_KEY
secrets/tailscale_auth_key:
	@printf "%s" "${TAILSCALE_AUTH_KEY}" > secrets/tailscale_auth_key
else
secrets/tailscale_auth_key:
	@echo "TAILSCALE_AUTH_KEY not defined, please set in env or on command line" >&2
	exit 1
endif

ifdef GOOGLE_OAUTH_CLIENT_ID
secrets/google_oauth_client_id:
	@printf "%s" "${GOOGLE_OAUTH_CLIENT_ID}" > secrets/google_oauth_client_id
else
secrets/google_oauth_client_id:
	@echo "GOOGLE_OAUTH_CLIENT_ID not defined, please set in env or on command line" >&2
	exit 1
endif

ifdef GOOGLE_OAUTH_CLIENT_SECRET
secrets/google_oauth_client_secret:
	@printf "%s" "${GOOGLE_OAUTH_CLIENT_SECRET}" > secrets/google_oauth_client_secret
else
secrets/google_oauth_client_secret:
	@echo "GOOGLE_OAUTH_CLIENT_SECRET not defined, please set in env or on command line" >&2
	exit 1
endif

ifdef SFTP_SSH_HOST_ED25519_KEY
secrets/sftp_ssh_host_ed25519_key:
	@printf "%s" "${SFTP_SSH_HOST_ED25519_KEY}" > secrets/sftp_ssh_host_ed25519_key
else
secrets/sftp_ssh_host_ed25519_key:
	@echo "SFTP_SSH_HOST_ED25519_KEY not defined, please set in env or on command line" >&2
	exit 1
endif

ifdef SFTP_SSH_HOST_RSA_KEY
secrets/sftp_ssh_host_rsa_key:
	@printf "%s" "${SFTP_SSH_HOST_RSA_KEY}" > secrets/sftp_ssh_host_rsa_key
else
secrets/sftp_ssh_host_rsa_key:
	@echo "SFTP_SSH_HOST_RSA_KEY not defined, please set in env or on command line" >&2
	exit 1
endif

clean_secrets_module:
	@rm -f modules/secrets/main.tf

modules/secrets/main.tf:
	@elixir secrets/make.exs --module

clean_cloud_run_secrets:
	@rm -f modules/cloud_run/secrets.tf

modules/cloud_run/secrets.tf:
	@elixir secrets/make.exs --cloud-run

cloud_sql_secrets: \
	clean_cloud_sql_secrets \
	secrets/google_cloud_sql_ca_cert \
	secrets/google_cloud_sql_cert \
	secrets/google_cloud_sql_privkey

clean_cloud_sql_secrets:
	@rm -f \
		secrets/google_cloud_sql_ca_cert \
		secrets/google_cloud_sql_cert \
		secrets/google_cloud_sql_privkey

ifdef ENV
secrets/google_cloud_sql_ca_cert:
	@cd envs/$(ENV) && terraform output -json cloud_sql_client_cert | $(JSON_PARSER) .server_ca_cert | base64 > ../../secrets/google_cloud_sql_ca_cert
else
secrets/google_cloud_sql_ca_cert:
	@echo "ENV not defined, please set in env or on command line" >&2
	@echo "(cloud sql secrets need to know which env to output from)" >&2
	exit 1
endif

ifdef ENV
secrets/google_cloud_sql_cert:
	@cd envs/$(ENV) && terraform output -json cloud_sql_client_cert | $(JSON_PARSER) .cert | base64 > ../../secrets/google_cloud_sql_cert
else
secrets/google_cloud_sql_cert:
	@echo "ENV not defined, please set in env or on command line" >&2
	@echo "(cloud sql secrets need to know which env to output from)" >&2
	exit 1
endif

ifdef ENV
secrets/google_cloud_sql_privkey:
	@cd envs/$(ENV) && terraform output -json cloud_sql_client_cert | $(JSON_PARSER) .private_key | base64 > ../../secrets/google_cloud_sql_privkey
else
secrets/google_cloud_sql_privkey:
	@echo "ENV not defined, please set in env or on command line" >&2
	@echo "(cloud sql secrets need to know which env to output from)" >&2
	exit 1
endif

load_secrets:
	@PROJECT=$(PROJECT) secrets/load \
		oban_key_fingerprint \
		oban_license_key \
		secret_key_base \
		datahub_cloak_key \
		datahub_metrics_auth_token \
		datahub_smtp_password \
		tailscale_auth_key \
		google_cloud_sql_ca_cert \
		google_cloud_sql_cert \
		google_cloud_sql_privkey \
		google_oauth_client_id \
		google_oauth_client_secret \
		sftp_ssh_host_ed25519_key \
		sftp_ssh_host_rsa_key \
		sftp_users

# ---

pr_qa:
	@gh pr create -B qa -H dev -t "dev -> qa" -b ""

pr_uat:
	@gh pr create -B uat -H qa -t "qa -> uat" -b ""

pr_prod:
	@gh pr create -B prod -H uat -t "uat -> prod" -b ""
