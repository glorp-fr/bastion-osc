

##############################################################################################################################
#
# Outscale provider
#
##############################################################################################################################


terraform {
  required_providers {
    outscale = {
      source = "outscale/outscale"
      version = "1.2.1"
    }
  }
}  



##############################################################################################################################
#
# Outscale access key
#
##############################################################################################################################

variable "access_key_id"  {}
variable "secret_key_id"  {}
variable "region"  {}

provider "outscale" {
  access_key_id = var.access_key_id
  secret_key_id = var.secret_key_id
  region = var.region
}

output "path" { value= path.module}
