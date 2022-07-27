output nodes_ips {
  value       = module.local.worker_ips
  sensitive   = false
  description = "Nodes IP addresses"
}
