packer {
  required_plugins {
    outscale = {
      version = ">= 1.5.0"
      source  = "github.com/outscale/outscale"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
  required_version = ">= 1.7.0, < 2.0.0"
}

variable "region" {
  type = string
  default = "eu-west-2"
}
variable "omi_source" {
  type =  string
  default = "ami-38d543f0" # debian_12
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}



source "outscale-bsu" "debian_12" {
  region = var.region
  vm_type = "tinav7.c4r8p2"
  ssh_username = "outscale"
  communicator = "ssh"
  ssh_interface = "public_ip"
  #ssh_keypair_name = var.keypair_name
  source_omi = var.omi_source
  omi_name = "deb12_splunk"
  #ssh_private_key_file = "./kp-splunk.pem"
  launch_block_device_mappings {
      delete_on_vm_deletion = true
      device_name = "/dev/sda1"
      volume_size = "100"
      volume_type = "gp2"
  }
}

build {
  name    = "deb12_bastion_jtt"
  sources = ["source.outscale-bsu.debian_12"]

  provisioner "shell" {
    inline = [
      "cloud-init status --wait",
    ]
  }
  provisioner "ansible" {
    playbook_file = "./ansible-recipe.yaml"
    extra_arguments = [ "--scp-extra-args", "'-O'" ]
  }
}
