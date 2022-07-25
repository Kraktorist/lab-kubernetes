output "worker_private_ips" {
  value = {for k, v in yandex_compute_instance.node: k => v.network_interface[0].ip_address}
}
output "worker_public_ips" {
  value = {for k, v in yandex_compute_instance.node: k => v.network_interface[0].nat_ip_address}
}
