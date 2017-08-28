variable "access_key" {
    type = "string"
    description = "AWS Access Key (nominally from ~/.aws/credentials)"
    default = ""
}

variable "secret_key" {
    type = "string"
    description = "AWS Secret Key (nominally from ~/.aws/credentials)"
    default = ""
}

variable "region" {
    type = "string"
    description = "AWS Region"
    default = "us-east-1"
}

variable "pem_path" {
    type = "string"
    description = "Path to EC2 secret key"
}

variable "key_name" {
    type = "string"
    description = "The name of your EC2 secret key"
}

variable "s3_uri" {
    type = "string"
    description = "Where to send EMR logs"
    default = "s3n://geotrellis-test/terraform-logs/"
}
