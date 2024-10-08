# create everything to build the datahub image for use in cloud run
#
module "datahub_cloud_build" {
  source  = "../../modules/cloud_build/datahub"
  env     = var.env
  project = var.project
  cloud_run_sa = module.cloud_run.service_account
}

# create the image repository
#
module "artifact_registry" {
  source               = "../../modules/artifact_registry"
  project              = var.project
  region               = var.region
  cloud_build_sa_email = module.datahub_cloud_build.cloud_build_sa.email
}

# create the database
#
module "cloud_sql" {
  source = "../../modules/cloud_sql"
  env    = var.env
  region = var.region
  tier   = var.tier
}

output "cloud_sql_instance" {
  value     = module.cloud_sql.db_instance
  sensitive = true
}

output "cloud_sql_password" {
  value     = module.cloud_sql.db_password
  sensitive = true
}

output "cloud_sql_client_cert" {
  value     = module.cloud_sql.client_cert
  sensitive = true
}

# create the cloud run service
#
module "cloud_run" {
  source             = "../../modules/cloud_run/datahub"
  db_connection_name = module.cloud_sql.db_instance.connection_name
  db_host            = module.cloud_sql.db_instance.private_ip_address
  db_password        = module.cloud_sql.db_password
  env                = var.env
  private_network    = module.cloud_sql.private_network
  project            = var.project
  region             = var.region
  phx_host           = var.phx_host
}

output "service" {
  value = module.cloud_run.service
  sensitive = true
}

# create a bastion instance
#
module "bastion" {
  source  = "../../modules/bastion"
  env     = var.env
  network = module.cloud_sql.private_network.name
  project = var.project
  zone    = var.zone
  cloud_sql_instance = module.cloud_sql.db_instance
}

output "bastion" {
  value = module.bastion.instance
  sensitive = true
}

# create SFTP service
#
module "sftp" {
  source  = "../../modules/sftp"
  env     = var.env
  image   = "ratiopbc/sftp:latest"
  network = module.cloud_sql.private_network.name
  project = var.project
  zone    = var.zone
}

output "sftp_ip" {
  value     = module.sftp.sftp_ip
  sensitive = true
}
