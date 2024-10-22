terraform {
  source = "${get_terragrunt_dir()}/../../"
}


inputs = {
  project_id       = "iac-infra"
  credentials_file = get_env("GOOGLE_APPLICATION_CREDENTIALS", "")
  region           = "europe-west1"
  environment      = "dev"
  subnet_cidr      = "10.0.0.0/16"
  node_count       = 1
  machine_type     = "n1-standard-1"
}


remote_state {
  backend = "gcs"
  config  = {
    bucket  = "terraform-q1-state-bucket"
    prefix  = "terraform/state/dev"
    project = "iac-infra"
  }
}

