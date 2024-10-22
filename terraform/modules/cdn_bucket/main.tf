resource "google_storage_bucket" "cdn_bucket" {
  name          = var.cdn_bucket_name
  location      = var.region
  force_destroy = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age    = 30
      with_state = "ARCHIVED"
    }
  }

  uniform_bucket_level_access = true

  storage_class = "STANDARD"  

}

