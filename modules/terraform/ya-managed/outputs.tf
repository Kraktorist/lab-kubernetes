output registry_id {
  value       = yandex_container_registry.registry.id
  sensitive   = false
  description = "Container Registry ID"
}

output "worker_public_ips" {
  value = {for k, v in yandex_kubernetes_cluster.k8s.master: v.internal_v4_address => v.external_v4_address}
}