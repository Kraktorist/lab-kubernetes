locals {
  ssh_user = "vagrant"
  ssh_private_key_file = "key"
  inventory_path = "hosts.yml"
  inventory = yamldecode(file("../inventory/hosts.yml"))["all"]
  nodes = merge(flatten([
    for group, members in local.inventory.children: [
      {for node, params in members.hosts:
        node => {
            group = group,
            name = params.name,
            cpu = params.cpu
            memory = params.memory
        }
      }
    ]
  ])...)

}

resource "virtualbox_vm" "node" {
  for_each = local.nodes
  name      = each.value.name
  image     = "https://app.vagrantup.com/ubuntu/boxes/focal64/versions/20220715.0.0/providers/virtualbox.box"
  cpus      = each.value.cpu
  memory    = each.value.memory
  # user_data = file("${path.module}/user_data")

  network_adapter {
    type           = "hostonly"
    host_interface = "enp5s1"
  }
}

resource "local_file" "hosts" {
    filename = local.inventory_path
    content     = <<-EOF
    ---
    all:
      hosts: %{ for instance in virtualbox_vm.node }
        ${instance.name}:
          ansible_host: ${instance.network_adapter.0.ipv4_address} %{ endfor }
      vars:
        ansible_connection_type: paramiko
        ansible_user: ${local.ssh_user}
    EOF
}

locals {
  ansible_inventory = {
    all = {
      vars = {
        ansible_user = local.ssh_user
        ansible_ssh_private_key_file = local.ssh_private_key_file
      }
      hosts = {}
      children = tomap(
        {
          for group, members in local.inventory.children:
            group => {
              hosts = {
                for node, params in members.hosts:
                    node => {
                    ansible_host = [
                        for v in virtualbox_vm.node:
                        v.network_adapter[0].ipv4_address if params.name == v.name
                    ][0]
                    # name = params.name,
                    # cpu = params.cpu
                    # memory = params.memory                    
                    }
              }
            }
        }
      )
    }
  }
}

resource "local_file" "ansible_inventory" {
    filename = "ansible_inventory.yml"
    content     = yamlencode(local.ansible_inventory)
}