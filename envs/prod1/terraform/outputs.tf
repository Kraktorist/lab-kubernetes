output nodes_private_ips {
  value       = module.ya-hosted.worker_private_ips
  sensitive   = false
  description = "Nodes private IP addresses"
}

output nodes_public_ips {
  value       = module.ya-hosted.worker_public_ips
  sensitive   = false
  description = "Nodes public IP addresses"
}
