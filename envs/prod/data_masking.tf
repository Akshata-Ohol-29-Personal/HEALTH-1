module "data_masking" {
  source  = "../../modules/cloud_build/data_masking"
  env     = var.env
  project = var.project
  region  = var.region
}

module "data_masking_cloud_run" {
  source                      = "../../modules/cloud_run/data_masking"
  env                         = var.env
  google_vpc_access_connector = module.cloud_run.vpc_access_connector
  private_network             = module.cloud_sql.private_network
  project                     = var.project
  region                      = var.region
}
