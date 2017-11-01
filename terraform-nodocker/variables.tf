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

variable "rpm_bucket" {
  type        = "string"
  description = "S3 Bucket containing RPMs (e.g. bucket if the whole path is s3://bucket/containing/rpms)"
}

variable "rpm_prefix" {
  type        = "string"
  description = "The prefix of the RPMS within the s3 bucket (e.g. containing/rpms if the whole path is s3://bucket/containing/rpms)"
}

variable "nb_bucket" {
  type        = "string"
  description = "S3 Bucket containing notebooks (e.g. bucket:/containing/notebooks)"
}

variable "jupyterhub_oauth_module" {
  type        = "string"
  description = "Name of the jupyterhub/oauthenticator module to import the jupyterhub_oauth_class from"
  default     = "github"
}

variable "jupyterhub_oauth_class" {
  type        = "string"
  description = "Name of the OAuth class provided by jupyterhub/oauthenticator"
  default     = "LocalGitHubOAuthenticator"
}

variable "oauth_client_id" {
  type        = "string"
  description = "Client ID token for OAuth server"
}

variable "oauth_client_secret" {
  type        = "string"
  description = "Client secret token for OAuth server"
}

variable "bid_price" {
  type        = "string"
  description = "Bid Price"
  default     = "0.06"
}
