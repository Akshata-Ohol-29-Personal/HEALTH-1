module "ph_service" {
  source  = "../../modules/cloud_build/ph_service"
  env     = var.env
  project = var.project
  region  = var.region
}

module "ph_service_cloud_run" {
  source                      = "../../modules/cloud_run/ph_service"
  env                         = var.env
  google_vpc_access_connector = module.cloud_run.vpc_access_connector
  private_network             = module.cloud_sql.private_network
  project                     = var.project
  region                      = var.region
}