module "datahub_cloud_build_trigger" {
  source                 = "../../modules/cloud_build/prod_trigger"
  datahub_cloud_build_sa = module.datahub_cloud_build.cloud_build_sa
  region                 = var.region
}
