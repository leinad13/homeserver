packer creates base image on proxmox with docker, qemu-guest-agent, sudo, ansible, git

terraform creates mediavm from the base image and runs scripts via ansible on the vm to set up the machine

ansible does automatic config on the machine

1. Run packer (from within /packer/ubuntu-server-mediavm)
    packer build -var-file='.\credentials.pkr.hcl' .\ubuntu-server-mediavm.pkr.hcl

2. Run Terraform (from within /terraform/)
    terraform apply

3. Run init-dockercompose.yaml from within vm with ansible using github personal access token
    ansible-playbook init-dockercompose.yaml --extra-vars "token=dsjkdnsakjdnsakjdnsak"