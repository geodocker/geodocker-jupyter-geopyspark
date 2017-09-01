# resource "aws_iam_role" "ecs-service" {
#   assume_role_policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": "sts:AssumeRole",
#             "Principal": {
#                 "Service": "ecs.amazonaws.com"
#             },
#             "Effect": "Allow",
#             "Sid": ""
#         }
#     ]
# }
# EOF
# }

# resource "aws_iam_role_policy_attachment" "ecs-service" {
#   role       = "${aws_iam_role.ecs-service.name}"
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerServiceFullAccess"
# }

# resource "aws_iam_instance_profile" "ecs-service" {
#   role = "${aws_iam_role.ecs-service.name}"
# }

# resource "aws_launch_configuration" "jupyterhub" {
#   iam_instance_profile = "${var.ecs_instance_profile}"
#   image_id             = "${var.ecs_ami}"
#   instance_type        = "m3.xlarge"
#   key_name             = "${var.key_name}"
#   security_groups      = ["${aws_security_group.security-group.id}"]
#   spot_price           = "0.05"

#   user_data = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.jupyterhub.name} >> /etc/ecs/ecs.config"

#   lifecycle {
#     create_before_destroy = true
#   }
# }

resource "aws_spot_instance_request" "cheap_worker" {
  ami                  = "${var.ecs_ami}"
  iam_instance_profile = "${var.ecs_instance_profile}"
  instance_type        = "m3.xlarge"
  key_name             = "${var.key_name}"
  security_groups      = ["${aws_security_group.security-group.name}"]
  spot_price           = "0.05"

  user_data = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.jupyterhub.name} >> /etc/ecs/ecs.config"
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
  task_definition = "${aws_ecs_task_definition.jupyterhub.arn}"
}

output "ecs-instance" {
  value = "${aws_spot_instance_request.cheap_worker.public_dns}"
}
