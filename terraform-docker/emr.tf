resource "aws_emr_cluster" "emr-spark-cluster" {
  name          = "GeoNotebook + GeoPySpark Cluster"
  applications  = ["Hadoop", "Spark", "Ganglia", "Zeppelin"]
  log_uri       = "${var.s3_uri}"
  release_label = "emr-5.7.0"
  service_role  = "${var.emr_service_role}"

  ec2_attributes {
    instance_profile = "${var.emr_instance_profile}"
    key_name         = "${var.key_name}"
    subnet_id        = "${var.subnet}"

    emr_managed_master_security_group = "${aws_security_group.security-group.id}"
    emr_managed_slave_security_group  = "${aws_security_group.security-group.id}"
  }

  instance_group {
    bid_price      = "${var.bid_price}"
    instance_count = 1
    instance_role  = "MASTER"
    instance_type  = "m3.xlarge"
    name           = "geopyspark-master"
  }

  instance_group {
    bid_price      = "${var.bid_price}"
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
