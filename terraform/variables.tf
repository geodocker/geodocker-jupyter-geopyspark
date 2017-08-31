variable "access_key" {
    type        = "string"
    description = "AWS Access Key (nominally from ~/.aws/credentials)"
    default     = ""
}

variable "secret_key" {
    type        = "string"
    description = "AWS Secret Key (nominally from ~/.aws/credentials)"
    default     = ""
}

variable "region" {
    type        = "string"
    description = "AWS Region"
    default     = "us-east-1"
}

variable "key_name" {
    type        = "string"
    description = "The name of the EC2 secret key (primarily for SSH access)"
}

variable "s3_uri" {
    type        = "string"
    description = "Where EMR logs will be sent"
    default     = "s3n://geotrellis-test/terraform-logs/"
}

variable "ecs_ami" {
    type        = "string"
    description = "AMI to use for the ECS Instance"
    default     = "ami-9eb4b1e5"
}

variable "jupyterhub_port" {
    type        = "string"
    description = "The port on which to connect to JupyterHub"
    default     = "8000"
}

variable "worker_count" {
    type        = "string"
    description = "The number of worker nodes"
    default     = "1"
}

variable "subnet" {
  type        = "string"
  description = "The subnet in which to launch the EMR cluster and the JupyterHub container"
}

variable "emr_service_role" {
  type        = "string"
  description = "EMR service role"
  default     = "EMR_DefaultRole"
}

variable "emr_instance_profile" {
  type        = "string"
  description = "EMR instance profile"
  default     = "EMR_EC2_DefaultRole"
}

variable "ecs_instance_profile" {
  type        = "string"
  description = "ECS instance profile"
  default     = "ecsInstanceRole"
}
