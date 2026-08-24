variable "proxmox_endpoint" {
  description = "Proxmox API endpoint"
  type        = string
  default     = "https://192.168.8.10:8006/"
}

variable "proxmox_node_name" {
  description = "Proxmox node name"
  type        = string
  default     = "lab-pve01"
}

variable "ssh_public_key" {
  description = "SSH public key used for VM access"
  type        = string
  sensitive   = true
}

variable "vm_password" {
  description = "Temporary VM console password"
  type        = string
  sensitive   = true
}
