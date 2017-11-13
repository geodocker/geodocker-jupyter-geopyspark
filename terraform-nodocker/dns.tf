data "aws_instance" "selected" {
  filter {
    name   = "dns-name"
    values = ["${aws_emr_cluster.emr-spark-cluster.master_public_dns}"]
  }
}

data "aws_subnet" "selected" {
  id = "${data.aws_instance.selected.subnet_id}"
}

resource "aws_route53_zone" "subdomain" {
  name   = "${var.subdomain}"
  # Comment-out the line below to create a public zone
  vpc_id = "${data.aws_subnet.selected.vpc_id}"
}

resource "aws_route53_record" "geotrellis" {
  zone_id = "${aws_route53_zone.subdomain.zone_id}"
  name    = "${aws_route53_zone.subdomain.name}"
  type    = "A"
  ttl     = "300"
  records = ["${data.aws_instance.selected.public_ip}"]
}

output "nameservers" {
  value = "${aws_route53_record.geotrellis.name_servers}"
}
