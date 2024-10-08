module "datahub_cloud_build_trigger" {
  source                 = "../../modules/cloud_build/non_prod_trigger"
  env                    = var.env
  region                 = var.region
  datahub_cloud_build_sa = module.datahub_cloud_build.cloud_build_sa
}
