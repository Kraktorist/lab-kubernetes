locals {
  # ssh_private_key_file = var.ssh_private_key_file != "" ? var.ssh_private_key_file : "${abspath(path.root)}/key"
  config = yamldecode(file(var.config))
  inventory = local.config.inventory.all
  params = local.config.params
  nodes = merge(flatten([
    [
      for group, members in try(local.inventory.children.k8s_cluster.children, {}): [
        {
          for node, params in members.hosts:
            node => {
                name = node,
                cpu = local.params[node].cpu
                memory = local.params[node].memory
            }
        }
      ]
    ],
    [
      for group, members in try(local.inventory.children.balancers, {}): [
        {
          for node, params in members:
            node => {
                name = node,
                cpu = local.params[node].cpu
                memory = local.params[node].memory
            }
        }
      ]        
    ]
  ])...)

}

resource "virtualbox_vm" "node" {
  for_each = local.nodes
  name      = each.value.name
  image     = var.image
  cpus      = each.value.cpu
  memory    = "${each.value.memory} mib"


  network_adapter {
    type           = "hostonly"
    host_interface = var.host_interface
  }
}

module name {
  source = "../ansible-inventory"
  vm = virtualbox_vm.node
  inventory = local.inventory
}
