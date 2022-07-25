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
  default     = "../hosts.yml"
  description = "List of machines to build"
}

variable ansible_inventory {
  type        = string
  default     = "../ansible/ansible_inventory.yml"
  description = "Ansible inventory file which will be outputed"
}

variable host_interface {
  type        = string
  default     = "enp5s1"
  description = "Host Network interface forbridged connection"
}

variable os_family {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "Operating System family"
}

variable subnet {
  type        = string
  default     = "192.168.0.0/16"
  description = "Subnet for instances"
}

variable network {
  type        = string
  default     = "lab-kubernetes"
  description = "Network name"
}
