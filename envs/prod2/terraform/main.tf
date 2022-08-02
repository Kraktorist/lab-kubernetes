data "yandex_iam_service_account" "k8s" {
  name = "lab-tf"
}

resource "yandex_vpc_network" "network" {
  name = var.network
}

resource "yandex_vpc_subnet" "subnet" {
  v4_cidr_blocks = [var.subnet]
  network_id     = yandex_vpc_network.network.id
}

resource "yandex_container_registry" "registry" {
  name      = var.registry_name
}

resource "yandex_kubernetes_cluster" "k8s" {
  name        = var.cluster_name
  description = var.cluster_description
  network_id = "${yandex_vpc_network.network.id}"
  master {
    version = var.cluster_version
    zonal {
      zone      = "${yandex_vpc_subnet.subnet.zone}"
      subnet_id = "${yandex_vpc_subnet.subnet.id}"
    }

    public_ip = true

    maintenance_policy {
      auto_upgrade = false
    }
  }

  service_account_id      = "${data.yandex_iam_service_account.k8s.id}"
  node_service_account_id = "${data.yandex_iam_service_account.k8s.id}"

  release_channel = "RAPID"
  network_policy_provider = var.network_provider
}

resource "yandex_kubernetes_node_group" "node_group" {
  cluster_id  = "${yandex_kubernetes_cluster.k8s.id}"
  name        = var.cluster_name
  description = var.cluster_description
  version     = var.cluster_version

  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat                = true
      subnet_ids         = ["${yandex_vpc_subnet.subnet.id}"]
    }

    resources {
      memory = 4
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    scheduling_policy {
      preemptible = false
    }

    container_runtime {
      type = var.container_runtime
    }
  }

  scale_policy {
    fixed_scale {
      size = 1
    }
  }

  allocation_policy {
    location {
      zone      = "${yandex_vpc_subnet.subnet.zone}"
    }
  }

  maintenance_policy {
    auto_upgrade = false
    auto_repair = true
  }
}