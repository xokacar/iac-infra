resource "google_compute_backend_bucket" "cdn_backend_bucket" {
  name        = "${var.cdn_bucket_name}-cdn-backend"
  bucket_name = var.cdn_bucket_name
  enable_cdn  = true  

  cdn_policy {
    cache_mode         = "CACHE_ALL_STATIC"
    default_ttl        = 3600  # 1 hour
    max_ttl            = 86400 # 1 day
    negative_caching   = true
    serve_while_stale  = 3600
  }
}

resource "google_compute_url_map" "cdn_url_map" {
  name            = "${var.cdn_bucket_name}-url-map"
  default_service = google_compute_backend_bucket.cdn_backend_bucket.id

  host_rule {
    hosts           = ["*"]
    path_matcher    = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_bucket.cdn_backend_bucket.id
  }
}

resource "google_compute_target_http_proxy" "cdn_http_proxy" {
  name   = "${var.cdn_bucket_name}-http-proxy"
  url_map = google_compute_url_map.cdn_url_map.id
}

resource "google_compute_global_forwarding_rule" "cdn_forwarding_rule" {
  name        = "${var.cdn_bucket_name}-cdn-forwarding-rule"
  target      = google_compute_target_http_proxy.cdn_http_proxy.id
  port_range  = "80"
  ip_protocol = "TCP"
}
