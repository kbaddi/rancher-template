#Captures available AZs
data "aws_availability_zones" "available" {}

resource "aws_vpc" "quickstart" {
  cidr_block = "${var.vpc-CIDR}"

  tags {
    Name = "${var.prefix}-vpc"
  }
}

# Public Subnet for Load Balancer

resource "aws_subnet" "Publicsubnet" {
  vpc_id            = "${aws_vpc.quickstart.id}"
  cidr_block        = "${var.Publicsubnet-CIDR}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "${var.prefix}-Publicsubnet"
  }
}

resource "aws_internet_gateway" "rancherui-igw" {
  vpc_id = "${aws_vpc.quickstart.id}"

  tags {
    Name = "${var.prefix}-igw"
  }
}

resource "aws_nat_gateway" "rancherui-natgw" {
  allocation_id = "${aws_eip.rancherui-eip.id}"
  subnet_id     = "${aws_subnet.Publicsubnet.id}"
  depends_on    = ["aws_internet_gateway.rancherui-igw"]

  tags {
    Name = "${var.prefix}-natgw"
  }
}



resource "aws_eip" "rancherui-eip" {
  vpc        = true
  depends_on = ["aws_internet_gateway.rancherui-igw"]

  tags {
    Name = "${var.prefix}-eip"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.quickstart.id}"

  tags {
    Name = "${var.prefix}-Public-route-table"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.rancherui-igw.id}"
  }
  tags {
    Name = "${var.prefix}-Public-rt"
  }


}

resource "aws_route_table_association" "Publicsubnet" {
  subnet_id      = "${aws_subnet.Publicsubnet.id}"
  route_table_id = "${aws_route_table.public.id}"
}

#Subnet for Rancher Master & worker Nodes

resource "aws_subnet" "Privatesubnet" {
  vpc_id            = "${aws_vpc.quickstart.id}"
  cidr_block        = "${var.Privatesubnet-CIDR}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"

  tags {
    name = "${var.prefix}-Privatesubnet"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.quickstart.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.rancherui-natgw.id}"
  }

  tags {
    name = "${var.prefix}-Private-rt"
  }
}


resource "aws_route_table_association" "Privatesubnet" {
  subnet_id      = "${aws_subnet.Privatesubnet.id}"
  route_table_id = "${aws_route_table.private.id}"
}
