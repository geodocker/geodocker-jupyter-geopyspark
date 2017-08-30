resource "aws_iam_role" "ecs-service" {
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ecs.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-service" {
  role       = "${aws_iam_role.ecs-service.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerServiceFullAccess"
}

resource "aws_iam_instance_profile" "ecs-service" {
  role = "${aws_iam_role.ecs-service.name}"
}

resource "aws_launch_configuration" "jupyterhub" {
  iam_instance_profile = "ecsInstanceRole" # XXX
  image_id             = "${var.ecs_ami}"
  instance_type        = "m3.xlarge"       # XXX
  key_name             = "${var.key_name}"
  security_groups      = ["${aws_security_group.security-group.id}"]
  spot_price           = "0.05"

  user_data = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.jupyterhub.name} >> /etc/ecs/ecs.config"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "jupyterhub" {
  health_check_type    = "EC2"
  launch_configuration = "${aws_launch_configuration.jupyterhub.id}"
  load_balancers       = ["${aws_elb.jupyterhub.id}"]
  vpc_zone_identifier  = ["${var.subnet}"]

  desired_capacity = 1
  max_size         = 1
  min_size         = 1
}

resource "aws_elb" "jupyterhub" {
  subnets         = ["${var.subnet}"]
  security_groups = ["${aws_security_group.security-group.id}"]

  listener {
    lb_port = 8000
    lb_protocol = "http"
    instance_port = 8000
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 2
    timeout = 3
    target = "TCP:22"
    interval = 5
  }
}

data "aws_instance" "emr-master" {
  filter {
    name   = "dns-name"
    values = ["${aws_emr_cluster.emr-spark-cluster.master_public_dns}"]
  }
}

data "template_file" "jupyterhub" {
  template = "${file("task-definitions/jupyterhub.json.template")}"

  vars {
    addr = "${data.aws_instance.emr-master.private_dns}"
    port = "${var.jupyterhub_port}"
  }
}

resource "aws_ecs_task_definition" "jupyterhub" {
  container_definitions = "${data.template_file.jupyterhub.rendered}"
  family                = "JupyterHub"
  network_mode          = "host"
}

resource "aws_ecs_cluster" "jupyterhub" {
  name = "JupyterHub_Cluster"
}

resource "aws_ecs_service" "jupyterhub" {
  name            = "JupyterHub_Service"
  cluster         = "${aws_ecs_cluster.jupyterhub.id}"
  desired_count   = 1
  iam_role        = "${aws_iam_role.ecs-service.name}"
  task_definition = "${aws_ecs_task_definition.jupyterhub.arn}"

  load_balancer {
    container_name = "jupyterhub"
    container_port = "${var.jupyterhub_port}"
    elb_name       = "${aws_elb.jupyterhub.name}"
  }
}
