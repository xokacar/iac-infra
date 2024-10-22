output "cdn_url" {
  value = "http://${google_compute_global_forwarding_rule.cdn_forwarding_rule.ip_address}"
}
