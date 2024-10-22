terraform {
  backend "gcs" {}
}

provider "google" {
    credentials = file(var.credentials_file)
    project     = var.project_id
    region      = var.region
}

module "vpc" {
  source      = "./modules/vpc"
  environment = var.environment
  subnet_cidr = var.subnet_cidr
  region      = var.region
}

module "gke" {
  source      = "./modules/gke"
  environment = var.environment
  region      = var.region
  node_count  = var.node_count
  machine_type = var.machine_type
  network     = module.vpc.vpc_name
  subnetwork  = module.vpc.subnet_name

  depends_on  = [module.vpc]
}

module "cdn_bucket" {
  source = "./modules/cdn_bucket"

  cdn_bucket_name = "cdn-q1-bucket-${var.environment}"
  environment = var.environment
  region      = var.region
}

module "cdn" {
  source = "./modules/cdn"

  cdn_bucket_name = module.cdn_bucket.cdn_bucket_name
  environment = var.environment
  region      = var.region
}


