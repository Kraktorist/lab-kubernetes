locals {
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
                disk = local.params[node].disk
                public_ip = local.params[node].public_ip
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
                disk = local.params[node].disk
                public_ip = local.params[node].public_ip
            }
        }
      ]        
    ]
  ])...)

}

data "yandex_compute_image" "os" {
  family = var.os_family
}

resource "yandex_vpc_network" "network" {
  name = var.network
}

resource "yandex_vpc_subnet" "subnet" {
  v4_cidr_blocks = [var.subnet]
  network_id     = yandex_vpc_network.network.id
}

resource "yandex_compute_instance" "node" {
  for_each = local.nodes
  name = each.value.name
  resources {
    cores  = each.value.cpu
    memory = each.value.memory/1024
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat = each.value.public_ip
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.os.id
      size = each.value.disk
    }
  }
  metadata = {
    type      = each.key
    ssh-keys = "${var.ssh_user}:${file(var.ssh_private_key_file)}"
  }
}

module name {
  source = "../ansible-inventory"
  vm = yandex_compute_instance.node
  inventory = local.inventory
  ssh_user = var.ssh_user
}
