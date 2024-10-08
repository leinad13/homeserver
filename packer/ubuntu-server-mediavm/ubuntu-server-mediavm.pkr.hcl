packer {
  required_plugins {
    name = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
    sensitive = true
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}

source "proxmox" "ubuntu-server-mediavm" {

    # Proxmox Connection Settings
    proxmox_url = var.proxmox_api_url
    username = var.proxmox_api_token_id
    token = var.proxmox_api_token_secret

    # VM General Settings
    node = "proxmox"
    vm_id = 409
    vm_name = "ubuntu-server-mediavm"
    template_description = "Ubuntu Server MediaVM"

    #VM OS Settings
    iso_file = "local:iso/ubuntu-24.04.1-live-server-amd64.iso"

    # VM Agent
    qemu_agent = true

    # VM Hard Disks
    scsi_controller = "virtio-scsi-pci"

    disks {
        disk_size = "40G"
        format = "raw"
        storage_pool = "local-lvm"
        storage_pool_type = "lvm"
        type = "sata"
    }

    # CPU
    cores = "4"

    # Memory
    memory = "6144"

    # Network
    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        firewall = "false"
    }

    # Cloud Init Settings
    cloud_init = true
    cloud_init_storage_pool = "local-lvm"

    # Packer Boot Commands
 /*    boot_command = [
        "<esc><wait><esc><wait>",
        "<f6><wait><esc><wait>",
        "<bs><bs><bs><bs><bs>",
        "autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
        "--- <enter>"
    ] */
    boot_command = [
        "c<wait>linux /casper/vmlinuz --- autoinstall ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'<enter><wait5s>initrd /casper/initrd <enter><wait5s>boot <enter><wait5s>"
    ]
    #boot_key_interval = "500ms"
    boot = "c"
    boot_wait = "10s"

    http_directory = "http"
    # (Optional) Bind IP Address and Port
    http_bind_address = "192.168.0.46"
    http_port_min = 8802
    http_port_max = 8802

    ssh_username = "dan"
    ssh_private_key_file = "~/.ssh/id_rsa"

    ssh_timeout = "30m" 
}

build {
    name = "ubuntu-server-mediavm"
    sources = ["source.proxmox.ubuntu-server-mediavm"]

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo sync"
        ]
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
    provisioner "file" {
        source = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }

    # Provisioning the VM Template with Docker Installation #4
    provisioner "shell" {
        inline = [
            "sudo apt-get install -y ca-certificates curl gnupg lsb-release",
            "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
            "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
            "sudo apt-get -y update",
            "sudo apt-get install -y docker-ce docker-ce-cli containerd.io"
        ]
    }


}