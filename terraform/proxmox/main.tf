resource "proxmox_download_file" "ubuntu_2404" {
  content_type = "import"
  datastore_id = "local"
  node_name    = var.proxmox_node_name

  url = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"

  file_name = "noble-server-cloudimg-amd64.qcow2"

  overwrite = false
}

locals {
  kubernetes_nodes = {
    "k8s-cp01" = {
      vm_id  = 101
      cores  = 2
      memory = 4096
      disk   = 32
      ip     = "192.168.8.30/24"
    }

    "k8s-wk01" = {
      vm_id  = 102
      cores  = 2
      memory = 4096
      disk   = 40
      ip     = "192.168.8.31/24"
    }

    "k8s-wk02" = {
      vm_id  = 103
      cores  = 2
      memory = 4096
      disk   = 40
      ip     = "192.168.8.32/24"
    }
  }
}

resource "proxmox_virtual_environment_vm" "kubernetes_nodes" {
  for_each = local.kubernetes_nodes

  name      = each.key
  node_name = var.proxmox_node_name
  vm_id     = each.value.vm_id

  agent {
    enabled = true
  }

  stop_on_destroy = true

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = "local-lvm"

    import_from = proxmox_download_file.ubuntu_2404.id

    interface = "virtio0"
    iothread  = true
    discard   = "on"
    size      = each.value.disk
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    datastore_id = "local-lvm"

    ip_config {
      ipv4 {
        address = each.value.ip
        gateway = "192.168.8.1"
      }
    }

    user_account {
      username = "ubuntu"

      keys = [
        var.ssh_public_key
      ]
    password = var.vm_password
    }
  }
}
