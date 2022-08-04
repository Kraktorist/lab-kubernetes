output nodes_ips {
  value       = module.ya-managed.worker_public_ips
  sensitive   = false
  description = "Nodes public IP addresses"
}

output registry_address {
  value       = format("cr.yandex/%s",module.ya-managed.registry_id)
  sensitive   = false
  description = "Registry URL"
}