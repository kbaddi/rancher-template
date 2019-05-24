# Configure the Amazon AWS Provider
provider "aws" {
  profile = "c12eindia"
  region  = "${var.region}"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_cloudinit_config" "rancherserver-cloudinit" {
  part {
    content_type = "text/cloud-config"
    content      = "hostname: ${var.prefix}-rancherserver\nmanage_etc_hosts: true"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.userdata_server.rendered}"
  }
}

resource "aws_instance" "rancherserver" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.server_instance_type}"
  key_name               = "${var.ssh_key_name}"
  user_data              = "${data.template_cloudinit_config.rancherserver-cloudinit.rendered}"
  vpc_security_group_ids = ["${aws_security_group.rancher_master_sg.id}", "${aws_security_group.internal-sg.id}"]
  subnet_id              = "${aws_subnet.Privatesubnet.id}"

  tags {
    Name = "${var.prefix}-rancherserver"
  }
}

data "template_cloudinit_config" "rancheragent-all-cloudinit" {
  count = "${var.count_agent_all_nodes}"

  part {
    content_type = "text/cloud-config"
    content      = "hostname: ${var.prefix}-rancheragent-${count.index}-all\nmanage_etc_hosts: true"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.userdata_agent.rendered}"
  }
}

resource "aws_instance" "rancheragent-all" {
  count                  = "${var.count_agent_all_nodes}"
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.worker_instance_type}"
  key_name               = "${var.ssh_key_name}"
  user_data              = "${data.template_cloudinit_config.rancheragent-all-cloudinit.*.rendered[count.index]}"
  vpc_security_group_ids = ["${aws_security_group.internal-sg.id}"]
  subnet_id              = "${aws_subnet.Privatesubnet.id}"

  tags {
    Name = "${var.prefix}-rancheragent-${count.index}-all"
  }
}

data "template_cloudinit_config" "rancheragent-etcd-cloudinit" {
  count = "${var.count_agent_etcd_nodes}"

  part {
    content_type = "text/cloud-config"
    content      = "hostname: ${var.prefix}-rancheragent-${count.index}-etcd\nmanage_etc_hosts: true"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.userdata_agent.rendered}"
  }
}

resource "aws_instance" "rancheragent-etcd" {
  count                  = "${var.count_agent_etcd_nodes}"
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.worker_instance_type}"
  key_name               = "${var.ssh_key_name}"
  vpc_security_group_ids = ["${aws_security_group.internal-sg.id}"]
  user_data              = "${data.template_cloudinit_config.rancheragent-etcd-cloudinit.*.rendered[count.index]}"

  tags {
    Name = "${var.prefix}-rancheragent-${count.index}-etcd"
  }
}

data "template_cloudinit_config" "rancheragent-controlplane-cloudinit" {
  count = "${var.count_agent_controlplane_nodes}"

  part {
    content_type = "text/cloud-config"
    content      = "hostname: ${var.prefix}-rancheragent-${count.index}-controlplane\nmanage_etc_hosts: true"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.userdata_agent.rendered}"
  }
}

resource "aws_instance" "rancheragent-controlplane" {
  count                  = "${var.count_agent_controlplane_nodes}"
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.worker_instance_type}"
  key_name               = "${var.ssh_key_name}"
  vpc_security_group_ids = ["${aws_security_group.internal-sg.id}"]
  user_data              = "${data.template_cloudinit_config.rancheragent-controlplane-cloudinit.*.rendered[count.index]}"

  tags {
    Name = "${var.prefix}-rancheragent-${count.index}-controlplane"
  }
}

data "template_cloudinit_config" "rancheragent-worker-cloudinit" {
  count = "${var.count_agent_worker_nodes}"

  part {
    content_type = "text/cloud-config"
    content      = "hostname: ${var.prefix}-rancheragent-${count.index}-worker\nmanage_etc_hosts: true"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.userdata_agent.rendered}"
  }
}

resource "aws_instance" "rancheragent-worker" {
  count                  = "${var.count_agent_worker_nodes}"
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.worker_instance_type}"
  key_name               = "${var.ssh_key_name}"
  vpc_security_group_ids = ["${aws_security_group.internal-sg.id}"]
  user_data              = "${data.template_cloudinit_config.rancheragent-worker-cloudinit.*.rendered[count.index]}"
  subnet_id              = "${aws_subnet.Privatesubnet.id}"

  tags {
    Name = "${var.prefix}-rancheragent-${count.index}-worker"
  }
}

data "template_file" "userdata_server" {
  template = "${file("files/userdata_server")}"

  vars {
    admin_password        = "${var.admin_password}"
    cluster_name          = "${var.cluster_name}"
    docker_version_server = "${var.docker_version_server}"
    rancher_version       = "${var.rancher_version}"
  }
}

data "template_file" "userdata_agent" {
  template = "${file("files/userdata_agent")}"

  vars {
    admin_password       = "${var.admin_password}"
    cluster_name         = "${var.cluster_name}"
    docker_version_agent = "${var.docker_version_agent}"
    rancher_version      = "${var.rancher_version}"
    server_address       = "${aws_instance.rancherserver.public_ip}"
  }
}

# Jump host

resource "aws_instance" "jumphost" {
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "${var.server_instance_type}"
  key_name                    = "${var.ssh_key_name}"
  user_data                   = "${data.template_cloudinit_config.rancherserver-cloudinit.rendered}"
  vpc_security_group_ids      = ["${aws_security_group.jump-sg.id}"]
  subnet_id                   = "${aws_subnet.Publicsubnet.id}"
  associate_public_ip_address = "True"

  tags {
    Name = "${var.prefix}-jumphost"
  }
}

// output "rancher-url" {
//   value = ["https://${aws_instance.rancherserver.public_ip}"]
// }

