variable "cdn_bucket_name" {
  description = "The name of the GCS bucket for CDN"  
  type        = string
}

variable "environment" {
  description = "The environment name (dev/staging/prod)"
  type        = string
}

variable "region" {
  description = "The region for the CDN setup"
  type        = string
}
