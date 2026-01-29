


locals {
  #trigger = join("-", ["JTT", formatdate("YYYYMMDDhhmmss", timestamp())])
  trigger = "demo-image-v1"
  packer_init_demo = terraform_data.packer_init_demo.output
  omi_delete = terraform_data.packer_build_demo.output
  keypair_name = "kp-demo"
}

#############################################################################################################################
#
# Keypair
#
#############################################################################################################################

resource "tls_private_key" "kp-demo" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "local_file" "kp-demo" {
  filename        = "${path.module}/kp-demo.pem"
  content         = tls_private_key.kp-demo.private_key_pem
  file_permission = "0600"
}

resource "outscale_keypair" "kp-demo" {
  keypair_name = "kp-demo"
  public_key = tls_private_key.kp-demo.public_key_openssh
}


#############################################################################################################################
#
# Lancement de Packer demo
#
#############################################################################################################################


resource "terraform_data" "packer_init_demo" {
  input =  local.trigger

  provisioner "local-exec" {
    working_dir = "./"
    command = "packer init vm_demo.pkr.hcl" 
  }
}


resource "terraform_data" "packer_build_demo" {
  input = local.packer_init_demo
  
  provisioner "local-exec" {
    working_dir = "./"
    environment = {
    OUTSCALE_ACCESSKEYID = "${var.access_key_id}"
    OUTSCALE_SECRETKEYID = "${var.secret_key_id}"

    }
    command = "packer build vm_bastion.pkr.hcl" 
  
  }
}


data "outscale_images" "bastion" {
  filter {
   name = "image_names"
   values = ["*bastion*"]
  }
  depends_on = [
    terraform_data.packer_build_demo
  ]
}

#############################################################################################################################
#
# VM NET1 = Serveur bastion
#
#############################################################################################################################

resource "outscale_vm" "demo" {
    image_id  = tolist(data.outscale_images.demo.images)[0].image_id
    vm_type                  = "tinav7.c4r8p2"
    keypair_name_wo          = "kp-demo"
    subnet_id = outscale_subnet.demo_net_sn1.subnet_id
    security_group_ids = [outscale_security_group.demo_net_sn1_sg.security_group_id]
    tags {
        key   = "name"
        value = "bastion"
    }
    user_data                = base64encode(<<EOF
    <CONFIGURATION>
    EOF
    )
}

resource "outscale_public_ip" "demo_pub_ip"{
	tags {
	key="Name"
	value="IP_demo"
  }
}



resource "outscale_public_ip_link" "public_ip_link_demo" {
    vm_id     = outscale_vm.demo.vm_id
    public_ip = outscale_public_ip.demo_pub_ip.public_ip
}
