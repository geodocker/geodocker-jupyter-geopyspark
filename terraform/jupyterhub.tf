resource "aws_security_group" "jupyterhub" {
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

  depends_on = ["aws_subnet.emr-spark-cluster"]

  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_elb" "jupyterhub" {}

resource "aws_launch_configuration" "jupyterhub" {
  associate_public_ip_address = true
  image_id                    = "${var.ecs_ami}"
  instance_type               = "m3.xlarge"
  key_name                    = "${var.key_name}"
  security_groups             = ["${aws_security_group.jupyterhub.id}"]
  spot_price                  = "0.05"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "jupyterhub" {
  launch_configuration = "${aws_launch_configuration.jupyterhub.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.emr-spark-cluster.id}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_task_definition" "jupyterhub" {
  container_definitions = "${file("task-definitions/jupyterhub.json")}"
  family                = "JupyterHub"
  network_mode          = "host"
}

resource "aws_ecs_cluster" "jupyterhub" {
  name = "JupyterHub"
}

resource "aws_ecs_service" "jupyterhub" {
  name            = "jupyterhub"
  cluster         = "${aws_ecs_cluster.jupyterhub.id}"
  task_definition = "${aws_ecs_task_definition.jupyterhub.arn}"
  desired_count   = 1

  load_balancer {
    # elb_name       = "${aws_elb.jupyterhub.name}"
    container_name = "jupyterhub"
    container_port = "${var.jupyterhub_port}"
  }
}

output "ecs-id" {
  value = "${aws_ecs_service.jupyterhub.cluster.id}"
}
