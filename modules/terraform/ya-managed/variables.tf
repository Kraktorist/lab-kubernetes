variable service_account {
  type        = string
  default     = "lab-tf"
  description = "Cluster Service Account (must be precreated)"
}


variable network {
  type        = string
  default     = "lab-kubernetes"
  description = "Network name"
}

variable subnet {
  type        = string
  default     = "192.168.0.0/16"
  description = "Subnet for instances"
}

variable cluster_version {
  type        = string
  default     = "1.22"
  description = "Kubernetes cluster version"
}

variable cluster_name {
  type        = string
  default     = "lab-kubernetes"
  description = "Kubernetes Cluster Name"
}

variable cluster_description {
  type        = string
  default     = "lab-kubernetes"
  description = "Kubernetes Cluster Description"
}

variable network_provider {
  type        = string
  default     = "CALICO"
  description = "Kubernetes Network Policy Provider"
}

variable container_runtime {
  type        = string
  default     = "containerd"
  description = "Kubernetes Container Runtime"
}

variable node_cpu_cores {
  type        = string
  default     = 2
  description = "CPU Cores"
}

variable node_memory {
  type        = string
  default     = 4
  description = "Node Memory"
}

variable node_disk {
  type        = string
  default     = 64
  description = "Node Disk"
}



variable registry_name {
  type        = string
  default     = "lab-kubernetes"
  description = "Container Registry Name"
}
