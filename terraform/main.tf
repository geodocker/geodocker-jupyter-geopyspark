provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_vpc" "emr-spark-cluster" {
  cidr_block           = "172.31.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "emr-spark-cluster" {
  vpc_id            = "${aws_vpc.emr-spark-cluster.id}"
  cidr_block        = "172.31.1.0/24"
}

resource "aws_emr_cluster" "emr-spark-cluster" {
  name          = "GeoNotebook + GeoPySpark Cluster"
  applications  = ["Hadoop", "Spark", "Ganglia", "Zeppelin"]
  log_uri       = "${var.s3_uri}"
  release_label = "emr-5.7.0"
  service_role  = "EMR_DefaultRole"

  ec2_attributes {
    instance_profile = "EMR_EC2_DefaultRole"
    key_name         = "${var.key_name}"
    subnet_id        = "${aws_subnet.emr-spark-cluster.id}"
  }

  instance_group {
    bid_price      = "0.05"
    instance_count = 1
    instance_role  = "MASTER"
    instance_type  = "m3.xlarge"
    name           = "geopyspark-master"
  }

  instance_group {
    bid_price      = "0.05"
    instance_count = "${var.worker_count}"
    instance_role  = "CORE"
    instance_type  = "m3.xlarge"
    name           = "geopyspark-core"
  }
}

output "emr-id" {
  value = "${aws_emr_cluster.emr-spark-cluster.id}"
}

output "emr-master" {
  value = "${aws_emr_cluster.emr-spark-cluster.master_public_dns}"
}
