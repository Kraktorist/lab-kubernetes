output "worker_ips" {
  value = {for k, v in virtualbox_vm.node: k => v.network_adapter[0].ipv4_address}
}