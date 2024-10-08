locals {
  ip = "192.168.0.215"
  gateway = "192.168.0.1"
  dns = "192.168.0.1"
  username = "dan"
}

resource "proxmox_vm_qemu" "mediavm1" {

    name = "toolsvm"
    desc = "Tools VM"
    vmid = "401"
    target_node = "proxmox"
    agent = 1

    clone = "ubuntu-server-mediavm"
    cores = 4
    sockets = 1
    cpu = "host"
    memory = 2048
    
    network {
        bridge = "vmbr0"
        model = "virtio"
    }

    disks {
        ide {
            ide3 {
                cloudinit {
                  storage = "local-lvm"
                }
            }
        }
        sata {
            sata0 {
                disk {
                    format = "raw"
                    storage = "local-lvm"
                    size = "50G"
                }
            }
        }
    }

    os_type = "cloud-init"
    ipconfig0 = "ip=${local.ip}/24,gw=${local.gateway}"
    nameserver = local.dns
    ciuser = local.username
    sshkeys = <<EOF
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCSG/QChWp2Fy345lCtHS95HdlNFOs5PxYwJnaaBcO2/VQ6FdsQ8tb1MIjPgo6rr1YDTdrHlZ78gS1n76AKcQTv4YSfNePYbjEa1RiJIWI6BL/pTZSnWZe0Uofea/JY1bhG9pKHbNNk8YT6E82l6k5SHoKHV816kG0BnHAmOCyvnm7BKd6hUqbE17d8zDzQ24OB23TGtvINB4a8oF/svCY6y1A1MuZ3CEc+JCRVElbUmYJRmU77MWHIU5KMSKE/M4TIXR95pq6PRynlnnXCqxtgqhsYOONFuZCDbza1RnyphBWCkGZwuREcv6JVL7y77l7Z8dNHie83igSzdkBQmYo56UJ9gNcZigzJyugt7qxy6SEV5jHDHurYqWQCyj6f0Qo3SbqkGk/yIb3KohclNYgO7aHETe8oh8KDnuYOqH/yvUwk/osqpWX+quvq033C3B9ZzJG+sbx8egOfr34F31Pbb5zuT5CLtyZFj++RL4ayIaQQA4GYcvyBXACMkY2sYds= dan@DESKTOP-1FJG695
    EOF

    provisioner "remote-exec" {

        connection {
          host = local.ip
          user = local.username
          type = "ssh"
          private_key = file("~/.ssh/id_rsa")
        }

        inline = [ 
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "ip a"
        ]
    }

}

