# bootstrap.sh
resource "aws_s3_bucket_object" "bootstrap" {
  bucket = "${var.bs_bucket}"
  key    = "${var.bs_prefix}/bootstrap.sh"
  source = "./bootstrap.sh"
  etag   = "${md5(file("./bootstrap.sh"))}"
}
