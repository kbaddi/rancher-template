resource "aws_security_group" "rancher_master_sg" {
  name        = "${var.prefix}-rancher-master-sg"
  description = "Allow HTTP connections from Internet."

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["${var.Publicsubnet-CIDR}"]
  }

  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["${var.Publicsubnet-CIDR}"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["${var.Publicsubnet-CIDR}"]
  }

  vpc_id = "${aws_vpc.quickstart.id}"

  tags {
    Name = "${var.prefix}-rancher-master"
  }
}

# Security Group for the Load Balaner. Allows inbound on 80 and 443 and outbound on all.

resource "aws_security_group" "rancherui-sg" {
  name        = "${var.prefix}-rancherui-sg"
  description = "Allow incoming HTTP connections."

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["${var.Privatesubnet-CIDR}"]
  }

  vpc_id = "${aws_vpc.quickstart.id}"

  tags {
    Name = "${var.prefix}-rancherui-sg"
  }
}

# Security Group for jump host to allow ssh from internet

resource "aws_security_group" "jump-sg" {
  name        = "${var.prefix}-jump-sg"
  description = "Allow incoming SSH connections."

  ingress {
    from_port   = 0
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.quickstart.id}"

  tags {
    Name = "${var.prefix}-jump-sg"
  }
}

resource "aws_security_group" "internal-sg" {
  name        = "${var.prefix}-internal-sg"
  description = "Allow SSH connections to Public Subnet"

  ingress {
    from_port   = 0
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.Publicsubnet-CIDR}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["${var.Publicsubnet-CIDR}"]
  }

  vpc_id = "${aws_vpc.quickstart.id}"

  tags {
    Name = "${var.prefix}-internal-sg"
  }
}
