
##############################################################################################################
#Security Group Net1 Vlan 1
# IN : icmp, SSH
# OUT: icmp, SSH,oversec UDP, iperf, HTTP,HTTPS,FTP
##############################################################################################################
resource "outscale_security_group" "demo_net_sn1_sg" {
	description = "Sec group demo bastion net sn1"
	security_group_name = "demo_net_sn1_sg"
	net_id =outscale_net.demo_net.net_id
}

################################
#   IN
################################
resource "outscale_security_group_rule" "demo_net_sn1_SSH_in" {
	flow = "Inbound"
	security_group_id = outscale_security_group.demo_net_sn1_sg.security_group_id
	from_port_range = "22"
	to_port_range = "22"
	ip_protocol = "tcp"
	ip_range = "86.207.107.223/32" #Replace with your own IP
}

resource "outscale_security_group_rule" "demo_net_sn1_http_demo" {
	flow = "Inbound"
	security_group_id = outscale_security_group.demo_net_sn1_sg.security_group_id
	from_port_range = "9090"
	to_port_range = "9090"
	ip_protocol = "tcp"
	ip_range = "86.207.107.223/32" #Replace with your own IP
}
