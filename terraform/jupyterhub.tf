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

resource "aws_security_group" "jupyterhub" {
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "${var.jupyterhub_port}"
    to_port     = "${var.jupyterhub_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "jupyterhub" {
  image_id             = "${var.ecs_ami}"
  instance_type        = "m3.xlarge" # XXX
  key_name             = "${var.key_name}"
  security_groups      = ["${aws_security_group.jupyterhub.id}"]
  spot_price           = "0.05"
  iam_instance_profile = "ecsInstanceRole" # XXX
  user_data = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.jupyterhub.name} >> /etc/ecs/ecs.config"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "jupyterhub" {
  max_size = 1
  min_size = 1
  availability_zones = ["us-east-1a"]
  launch_configuration = "${aws_launch_configuration.jupyterhub.id}"
  health_check_type = "EC2"
  desired_capacity = 1
  load_balancers = ["${aws_elb.jupyterhub.id}"]
}

resource "aws_elb" "jupyterhub" {
  availability_zones = ["us-east-1a"]
  security_groups    = ["${aws_security_group.jupyterhub.id}"]

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

resource "aws_ecs_task_definition" "jupyterhub" {
  container_definitions = "${file("task-definitions/jupyterhub.json")}"
  family                = "JupyterHub"
}

resource "aws_ecs_cluster" "jupyterhub" {
  name = "JupyterHub"
}

resource "aws_ecs_service" "jupyterhub" {
  name            = "JupyterHub"
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
