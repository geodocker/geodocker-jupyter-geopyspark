variable "region" {
    type        = "string"
    description = "AWS Region"
    default     = "us-east-1"
}

variable "key_name" {
    type        = "string"
    description = "The name of the EC2 secret key (primarily for SSH access)"
}

variable "s3_log_uri" {
    type        = "string"
    description = "Where EMR logs will be sent"
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

variable "bs_bucket" {
  type        = "string"
  description = "S3 Bucket containing the bootstrap script (e.g. bucket if the whole path is s3://bucket/containing/bootstrap)"
}

variable "bs_prefix" {
  type        = "string"
  description = "The prefix of the bootstrap script within the s3 bucket (e.g. containing/bootstrap if the whole path is s3://bucket/containing/bootstrap/bootstrap.sh)"
}

variable "s3_rpm_uri" {
  type        = "string"
  description = "S3 path containing RPMs (e.g. s3://bucket/containing/rpms/)"
}

variable "s3_notebook_uri" {
  type        = "string"
  description = "S3 path for notebooks (e.g. s3://bucket/containing/notebooks/)"
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
  default     = "0.07"
}

variable "subdomain" {
  type        = "string"
  description = "Subdomain"
  default     = "geotrellis.example.com"
}
