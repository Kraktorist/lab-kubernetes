output name {
  value       = yandex_kubernetes_cluster.k8s
  sensitive   = false
  description = "description"
}

output "worker_public_ips" {
  value = {for k, v in yandex_kubernetes_cluster.k8s.master: v.internal_v4_address => v.external_v4_address}
}