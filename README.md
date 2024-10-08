yuvo health ops
===============

## Environments

| Name | GCP Project ID |
|-|-|
| `dev` | `precise-formula-368918` |
| `qa` | `ratiopbc-qa` |
| `uat` | `yuvo-uat` |
| `prod` | `yuvo-production` |

## Branching

The following branching strategy is use to promote changes from dev to prod:

`prod` <- `uat` <- `qa` <- `dev` <- feature branch

New changes should be made in feature branches and PRs created targetting the
`dev` branch. Opening the PR will trigger a plan, merging the PR will trigger
an apply. Once changes are applied and tested in the dev environment, a PR may
be opened from `dev` to `qa`, which will trigger a plan, etc. repeat all the way
to `prod`.

## Terraform

### Manual Usage

For manual usage, run init/plan/apply from the desired `envs/` directory:

```bash
ops/ $ cd envs/dev

dev/ $ vim ../../modules/cloud_sql/main.tf
# make changes to a ../../modules/ file

dev/ $ terraform init
dev/ $ terraform plan
dev/ $ terraform apply
```

NOTE: though it does use a shared state bucket, care should be taken with manual
applies to ensure that automation may still continue when finished.

### New Environment Steps

First, run `make secrets` to create `secrets/*` files. Follow directions if values
not found. Confirm that the secrets files' contents are expected. These files'
content will be used to set the values in GCP Secret Manager.

Then, run `terraform init`, and `terraform apply` in the following dirs per env:

1. `apis/`
2. `state_bucket/`
3. `cloud_build/`
4. `secrets/` (see below)

Now the environment is set up for the plan/apply automation.

## Makefile

### `secrets` target

This make target creates files in the `secrets/` directory. These files are git
ignored. Generally, the values need to be set/available in the environment
before running. The targets will return an error for any values that aren't
defined at runtime. The values are written to files so Terraform can read the
contents and create Google Secret Manager secret versions. These files are
created, overwritten if existing:

* `secrets/oban_key_fingerprint`
* `secrets/oban_license_key`
* `secrets/secret_key_base`
* `secrets/datahub_cloak_key`
* `secrets/tailscale_auth_key`
* `secrets/google_oauth_client_id`
* `secrets/google_oauth_client_secret`

#### Examples

Values not set:

```sh
$ make secrets
OBAN_KEY_FINGERPRINT not defined, please set in env or on command line
exit 1
make: *** [secrets/oban_key_fingerprint] Error 1
```

Values set on command line:

```sh
$ make secrets \
    OBAN_LICENSE_KEY=abc \
    OBAN_KEY_FINGERPRINT=def \
    SECRET_KEY_BASE=ghi \
    DATAHUB_CLOAK_KEY=jkl \
    TAILSCALE_AUTH_KEY=mno \
    GOOGLE_OAUTH_CLIENT_ID=pqr \
    GOOGLE_OAUTH_CLIENT_SECRET=stu
```

### `cloud_sql_secrets` target

This target is for use after the Cloud SQL instance is created. That module
creates the outputs necessary to fetch the TLS certs needed to connect. The make
target uses terraform, the `ENV` value, and a JSON parser utility (defaults to
`jq`) to write the values to secret files for the shared `secrets` Terraform
module to set. These files are created, overwritten if existing:

* `secrets/google_cloud_sql_ca_cert`
* `secrets/google_cloud_sql_cert`
* `secrets/google_cloud_sql_privkey`

#### Examples

Values not set:

```sh
$ make cloud_sql_secrets
ENV not defined, please set in env or on command line
(cloud sql secrets need to know which env to output from)
exit 1
make: *** [secrets/google_cloud_sql_ca_cert] Error 1
```

Values set on command line ([fx](https://github.com/antonmedv/fx) is a great
alternative to [jq](https://stedolan.github.io/jq/)):

```sh
$ make cloud_sql_secrets ENV=dev JSON_PARSER=`which fx`
```

### `*.tf` targets

These are targets used to run Elixir scripts that generate repetivite Terraform
HCL. See `secrets/make.exs` for more info.

#### SFTP Host Key Secrets

Each environment has an SFTP server running, and needs a host key saved in a
secret so that it persists across service restarts. The best thing to do is
generate one at service creation time and store it in secrets using terraform.
Since they are multi-line files, they will need to be base64 encoded.

To generate a base64-encoded ed25519 key with no passphrase and comment
`sftp.yuvohealth.com` (change for intended hostname):

```bash
(mkfifo key && \
  ((cat key ; rm key key.pub)&) && \
    (echo y | ssh-keygen -C 'sftp.yuvohealth.com' -t ed25519 -N '' -q -f key > /dev/null)) \
    | base64
```

Replace `ed25519` with `rsa` in the above to generate an RSA key. Export these
values in the following keys for the make targets to pickup:

* `SFTP_SSH_HOST_ED25519_KEY`
* `SFTP_SSH_HOST_RSA_KEY`
