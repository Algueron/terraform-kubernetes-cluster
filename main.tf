terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = ">=1.0.0"
    }
  }
  required_version = ">= 0.13"
}

variable "pm_api_url" {
}

variable "pm_user" {
}

variable "pm_password" {
}

variable "ssh_key" {
#  default = "ssh-rsa ..."
}

provider "proxmox" {
  # Configuration options
  pm_api_url      = var.pm_api_url
  pm_user         = var.pm_user
  pm_password     = var.pm_password
  pm_tls_insecure = "true"
  pm_parallel     = 1
}

resource "proxmox_vm_qemu" "k8s_master" {
  count             = 3
  name              = "kubernetes-master-${count.index}"
  target_node       = "compute01"

  clone             = "ubuntu-2004-cloudinit-template"

  os_type           = "cloud-init"
  cores             = 2
  sockets           = "1"
  cpu               = "host"
  memory            = 4096
  scsihw            = "virtio-scsi-pci"
  bootdisk          = "scsi0"

  disk {
    size            = "20G"
    type            = "scsi"
    storage         = "pvecontent"
    iothread        = 1
  }

  nameserver        = "192.168.1.15"
  network {
    model           = "virtio"
    bridge          = "vmbr0"
  }

  lifecycle {
    ignore_changes  = [
      network,
    ]
  }

  # Cloud Init Settings
  ipconfig0         = "ip=192.168.0.12${count.index + 1}/24,gw=192.168.0.1"

  ciuser = "algueron"

  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}

resource "proxmox_vm_qemu" "k8s_worker" {
  count             = 5
  name              = "kubernetes-worker-${count.index}"
  target_node       = "compute01"

  clone             = "ubuntu-2004-cloudinit-template"

  os_type           = "cloud-init"
  cores             = 4
  sockets           = "1"
  cpu               = "host"
  memory            = 8192
  scsihw            = "virtio-scsi-pci"
  bootdisk          = "scsi0"

  disk {
    size            = "50G"
    type            = "scsi"
    storage         = "pvecontent2"
    iothread        = 1
  }

  nameserver        = "192.168.1.15"
  network {
    model           = "virtio"
    bridge          = "vmbr0"
  }

  lifecycle {
    ignore_changes  = [
      network,
    ]
  }

  # Cloud Init Settings
  ipconfig0         = "ip=192.168.0.13${count.index + 1}/24,gw=192.168.0.1"

  ciuser = "algueron"

  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}
