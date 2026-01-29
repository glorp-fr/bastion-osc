
##############################################################################################################################
#
# NET 1 : Net demo
#
##############################################################################################################################

resource "outscale_net" "demo_net" {
    ip_range = "10.1.0.0/16"
    tags {
        key="Name"
        value="demo_net"
    }
}

resource "outscale_subnet" "demo_net_sn1" {
    net_id = outscale_net.demo_net.net_id
    ip_range = "10.1.1.0/24"
    tags {
        key="Name"
        value="demo_net_sn1_public"
    }
}

#Internet service
resource "outscale_internet_service" "demo_net_www" {
	tags {
	key="Name"
	value="demo_net_www"
  }
}

resource "outscale_internet_service_link" "demo_net_www_link" {
  internet_service_id = outscale_internet_service.demo_net_www.internet_service_id
  net_id = outscale_net.demo_net.net_id
}

resource "outscale_route_table" "demo_net_sn1_rt" {
  net_id = outscale_net.demo_net.net_id
  tags {
    key="Name"
    value="demo_net_sn1_rt"
  }
}

resource "outscale_route" "demo_net_rt_def" {
  destination_ip_range = "0.0.0.0/0"
  route_table_id = outscale_route_table.demo_net_sn1_rt.route_table_id
  gateway_id = outscale_internet_service.demo_net_www.internet_service_id
}

resource "outscale_route_table_link" "demo_net_rtl" {
    subnet_id      = outscale_subnet.demo_net_sn1.subnet_id
    route_table_id = outscale_route_table.demo_net_sn1_rt.route_table_id
}
