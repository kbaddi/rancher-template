# Create a new load balancer
resource "aws_elb" "quickstart" {
  name = "quickstart-terraform-elb"

  # availability_zones = ["${data.aws_availability_zones.available.names[2]}"]
  subnets = ["${aws_subnet.Publicsubnet.id}"]

  // access_logs {
  //   bucket        = "rancher-env"
  //   bucket_prefix = "quickstart"
  //   interval      = 60
  // }
  #HTTP Listener
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  // #HTTPS listerner
  // listener {
  //   instance_port     = 443
  //   instance_protocol = "http"
  //   lb_port           = 443
  //   lb_protocol       = "https"
  //
  //   # ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
  // }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
  instances                   = ["${aws_instance.rancherserver.*.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  tags = {
    name = "quickstart-elb"
  }
}
