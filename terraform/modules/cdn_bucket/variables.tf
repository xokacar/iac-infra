variable "cdn_bucket_name" {
  description = "The name of the CDN bucket"  
  type        = string
}

variable "region" {
  description = "The region for the bucket"
  type        = string
}

variable "environment" {
  description = "The environment name (dev/staging/prod)"
  type        = string
}
