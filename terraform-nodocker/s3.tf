# bootstrap.sh
resource "aws_s3_bucket_object" "bootstrap" {
  bucket = "${var.rpm_bucket}"
  key    = "${var.rpm_prefix}/bootstrap.sh"
  source = "./bootstrap.sh"
  etag   = "${md5(file("./bootstrap.sh"))}"

  provisioner "local-exec" {
    command = "aws s3 sync ../rpms/build/rpmbuild/RPMS/x86_64/ s3://${var.rpm_bucket}/${var.rpm_prefix}/"
  }
}
