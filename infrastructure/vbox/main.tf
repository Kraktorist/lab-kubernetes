locals {
  # ssh_private_key_file = var.ssh_private_key_file != "" ? var.ssh_private_key_file : "${abspath(path.root)}/key"
  config = yamldecode(file(var.config))
  inventory = local.config.inventory.all
  params = local.config.params
  nodes = merge(flatten([
    [
      for group, members in local.inventory.children.k8s_cluster.children: [
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

locals {
  ansible_inventory = {
    all = {
      vars = {
        ansible_user = var.ssh_user
        # ansible_ssh_private_key_file = local.ssh_private_key_file
      }
      hosts = {}
      children = {
        k8s_cluster = {
          children = tomap(
            {
              for group, members in local.inventory.children.k8s_cluster.children:
                  group => {
                    hosts = {
                        for node, params in members.hosts:
                            node => {
                            ansible_host = [
                                for v in virtualbox_vm.node:
                                v.network_adapter[0].ipv4_address if node == v.name
                            ][0]                
                            }
                    }
                  }
            }
          )
        }
        balancers = tomap(
          {
            for group, members in try(local.inventory.children.balancers, {}):
                group => {
                      for node, params in members:
                          node => {
                          ansible_host = [
                              for v in virtualbox_vm.node:
                              v.network_adapter[0].ipv4_address if node == v.name
                          ][0]           
                          }
                }           
          }
        )
      }
    }
  }
}

resource "local_file" "ansible_inventory" {
    filename = var.ansible_inventory
    content     = yamlencode(local.ansible_inventory)
}