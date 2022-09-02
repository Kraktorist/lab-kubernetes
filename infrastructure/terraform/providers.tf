terraform {
  required_providers {
    virtualbox = {
      source = "terra-farm/virtualbox"
      version = "0.2.2-alpha.1"
    }
    yandex = {
      source = "terraform-registry.storage.yandexcloud.net/yandex-cloud/yandex"
      version = ">= 0.72"
    }
  }
}