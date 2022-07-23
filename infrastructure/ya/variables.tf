variable ssh_user {
  type = string
  default = "ubuntu"
  description = "The user to connect to built machines"
}

variable ssh_private_key_file {
  type = string
  default = "~/ya_key.pub"
  description = "The SSH key to connect to built machines"
}

variable config {
  type        = string
  default     = "../inventory/hosts.yml"
  description = "List of machines to build"
}

variable ansible_inventory {
  type        = string
  default     = "../inventory/ansible_inventory.yml"
  description = "Ansible inventory file which will be outputed"
}

variable host_interface {
  type        = string
  default     = "enp5s1"
  description = "Host Network interface forbridged connection"
}
