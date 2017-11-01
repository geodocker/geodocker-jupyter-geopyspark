# boost162-1_62_0-33.x86_64.rpm
resource "aws_s3_bucket_object" "boost162" {
  bucket = "${var.rpm_bucket}"
  key    = "${var.rpm_prefix}/boost162-1_62_0-33.x86_64.rpm"
  source = "../rpms/build/rpmbuild/RPMS/x86_64/boost162-1_62_0-33.x86_64.rpm"
  etag   = "${md5(file("../rpms/build/rpmbuild/RPMS/x86_64/boost162-1_62_0-33.x86_64.rpm"))}"
}

# boost162-lib-1_62_0-33.x86_64.rpm
resource "aws_s3_bucket_object" "boost162-lib" {
  bucket = "${var.rpm_bucket}"
  key    = "${var.rpm_prefix}/boost162-lib-1_62_0-33.x86_64.rpm"
  source = "../rpms/build/rpmbuild/RPMS/x86_64/boost162-lib-1_62_0-33.x86_64.rpm"
  etag   = "${md5(file("../rpms/build/rpmbuild/RPMS/x86_64/boost162-lib-1_62_0-33.x86_64.rpm"))}"
}

# freetype2-2.8-33.x86_64.rpm
resource "aws_s3_bucket_object" "freetype2" {
  bucket = "${var.rpm_bucket}"
  key    = "${var.rpm_prefix}/freetype2-2.8-33.x86_64.rpm"
  source = "../rpms/build/rpmbuild/RPMS/x86_64/freetype2-2.8-33.x86_64.rpm"
  etag   = "${md5(file("../rpms/build/rpmbuild/RPMS/x86_64/freetype2-2.8-33.x86_64.rpm"))}"
}

# freetype2-lib-2.8-33.x86_64.rpm
resource "aws_s3_bucket_object" "freetype2-lib" {
  bucket = "${var.rpm_bucket}"
  key    = "${var.rpm_prefix}/freetype2-lib-2.8-33.x86_64.rpm"
  source = "../rpms/build/rpmbuild/RPMS/x86_64/freetype2-lib-2.8-33.x86_64.rpm"
  etag   = "${md5(file("../rpms/build/rpmbuild/RPMS/x86_64/freetype2-lib-2.8-33.x86_64.rpm"))}"
}

# gcc6-6.4.0-33.x86_64.rpm
resource "aws_s3_bucket_object" "gcc6" {
  bucket = "${var.rpm_bucket}"
  key    = "${var.rpm_prefix}/gcc6-6.4.0-33.x86_64.rpm"
  source = "../rpms/build/rpmbuild/RPMS/x86_64/gcc6-6.4.0-33.x86_64.rpm"
  etag   = "${md5(file("../rpms/build/rpmbuild/RPMS/x86_64/gcc6-6.4.0-33.x86_64.rpm"))}"
}

# gcc6-lib-6.4.0-33.x86_64.rpm
resource "aws_s3_bucket_object" "gcc6-lib" {
  bucket = "${var.rpm_bucket}"
  key    = "${var.rpm_prefix}/gcc6-lib-6.4.0-33.x86_64.rpm"
  source = "../rpms/build/rpmbuild/RPMS/x86_64/gcc6-lib-6.4.0-33.x86_64.rpm"
  etag   = "${md5(file("../rpms/build/rpmbuild/RPMS/x86_64/gcc6-lib-6.4.0-33.x86_64.rpm"))}"
}

# gdal213-2.1.3-33.x86_64.rpm
resource "aws_s3_bucket_object" "gdal213" {
  bucket = "${var.rpm_bucket}"
  key    = "${var.rpm_prefix}/gdal213-2.1.3-33.x86_64.rpm"
  source = "../rpms/build/rpmbuild/RPMS/x86_64/gdal213-2.1.3-33.x86_64.rpm"
  etag   = "${md5(file("../rpms/build/rpmbuild/RPMS/x86_64/gdal213-2.1.3-33.x86_64.rpm"))}"
}

# gdal213-lib-2.1.3-33.x86_64.rpm
resource "aws_s3_bucket_object" "gdal213-lib" {
  bucket = "${var.rpm_bucket}"
  key    = "${var.rpm_prefix}/gdal213-lib-2.1.3-33.x86_64.rpm"
  source = "../rpms/build/rpmbuild/RPMS/x86_64/gdal213-lib-2.1.3-33.x86_64.rpm"
  etag   = "${md5(file("../rpms/build/rpmbuild/RPMS/x86_64/gdal213-lib-2.1.3-33.x86_64.rpm"))}"
}

# geonotebook-0.0.0-13.x86_64.rpm
resource "aws_s3_bucket_object" "geonotebook" {
  bucket = "${var.rpm_bucket}"
  key    = "${var.rpm_prefix}/geonotebook-0.0.0-13.x86_64.rpm"
  source = "../rpms/build/rpmbuild/RPMS/x86_64/geonotebook-0.0.0-13.x86_64.rpm"
  etag   = "${md5(file("../rpms/build/rpmbuild/RPMS/x86_64/geonotebook-0.0.0-13.x86_64.rpm"))}"
}

# geopyspark-0.2.2-13.x86_64.rpm
resource "aws_s3_bucket_object" "geopyspark" {
  bucket = "${var.rpm_bucket}"
  key    = "${var.rpm_prefix}/geopyspark-0.2.2-13.x86_64.rpm"
  source = "../rpms/build/rpmbuild/RPMS/x86_64/geopyspark-0.2.2-13.x86_64.rpm"
  etag   = "${md5(file("../rpms/build/rpmbuild/RPMS/x86_64/geopyspark-0.2.2-13.x86_64.rpm"))}"
}

# geopyspark-worker-0.2.2-13.x86_64.rpm
resource "aws_s3_bucket_object" "geopyspark-worker" {
  bucket = "${var.rpm_bucket}"
  key    = "${var.rpm_prefix}/geopyspark-worker-0.2.2-13.x86_64.rpm"
  source = "../rpms/build/rpmbuild/RPMS/x86_64/geopyspark-worker-0.2.2-13.x86_64.rpm"
  etag   = "${md5(file("../rpms/build/rpmbuild/RPMS/x86_64/geopyspark-worker-0.2.2-13.x86_64.rpm"))}"
}

# jupyterhub-0.7.2-13.x86_64.rpm
resource "aws_s3_bucket_object" "jupyterhub" {
  bucket = "${var.rpm_bucket}"
  key    = "${var.rpm_prefix}/jupyterhub-0.7.2-13.x86_64.rpm"
  source = "../rpms/build/rpmbuild/RPMS/x86_64/jupyterhub-0.7.2-13.x86_64.rpm"
  etag   = "${md5(file("../rpms/build/rpmbuild/RPMS/x86_64/jupyterhub-0.7.2-13.x86_64.rpm"))}"
}

# mapnik-093fcee-33.x86_64.rpm
resource "aws_s3_bucket_object" "mapnik" {
  bucket = "${var.rpm_bucket}"
  key    = "${var.rpm_prefix}/mapnik-093fcee-33.x86_64.rpm"
  source = "../rpms/build/rpmbuild/RPMS/x86_64/mapnik-093fcee-33.x86_64.rpm"
  etag   = "${md5(file("../rpms/build/rpmbuild/RPMS/x86_64/mapnik-093fcee-33.x86_64.rpm"))}"
}

# nodejs-8.5.0-13.x86_64.rpm
resource "aws_s3_bucket_object" "nodejs" {
  bucket = "${var.rpm_bucket}"
  key    = "${var.rpm_prefix}/nodejs-8.5.0-13.x86_64.rpm"
  source = "../rpms/build/rpmbuild/RPMS/x86_64/nodejs-8.5.0-13.x86_64.rpm"
  etag   = "${md5(file("../rpms/build/rpmbuild/RPMS/x86_64/nodejs-8.5.0-13.x86_64.rpm"))}"
}

# proj493-4.9.3-33.x86_64.rpm
resource "aws_s3_bucket_object" "proj493" {
  bucket = "${var.rpm_bucket}"
  key    = "${var.rpm_prefix}/proj493-4.9.3-33.x86_64.rpm"
  source = "../rpms/build/rpmbuild/RPMS/x86_64/proj493-4.9.3-33.x86_64.rpm"
  etag   = "${md5(file("../rpms/build/rpmbuild/RPMS/x86_64/proj493-4.9.3-33.x86_64.rpm"))}"
}

# proj493-lib-4.9.3-33.x86_64.rpm
resource "aws_s3_bucket_object" "proj493-lib" {
  bucket = "${var.rpm_bucket}"
  key    = "${var.rpm_prefix}/proj493-lib-4.9.3-33.x86_64.rpm"
  source = "../rpms/build/rpmbuild/RPMS/x86_64/proj493-lib-4.9.3-33.x86_64.rpm"
  etag   = "${md5(file("../rpms/build/rpmbuild/RPMS/x86_64/proj493-lib-4.9.3-33.x86_64.rpm"))}"
}

# python-mapnik-e5f107d-33.x86_64.rpm
resource "aws_s3_bucket_object" "python-mapnik" {
  bucket = "${var.rpm_bucket}"
  key    = "${var.rpm_prefix}/python-mapnik-e5f107d-33.x86_64.rpm"
  source = "../rpms/build/rpmbuild/RPMS/x86_64/python-mapnik-e5f107d-33.x86_64.rpm"
  etag   = "${md5(file("../rpms/build/rpmbuild/RPMS/x86_64/python-mapnik-e5f107d-33.x86_64.rpm"))}"
}

# s3fs-fuse-1.82-33.x86_64.rpm
resource "aws_s3_bucket_object" "s3fs" {
  bucket = "${var.rpm_bucket}"
  key    = "${var.rpm_prefix}/s3fs-fuse-1.82-33.x86_64.rpm"
  source = "../rpms/build/rpmbuild/RPMS/x86_64/s3fs-fuse-1.82-33.x86_64.rpm"
  etag   = "${md5(file("../rpms/build/rpmbuild/RPMS/x86_64/s3fs-fuse-1.82-33.x86_64.rpm"))}"
}

# bootstrap.sh
resource "aws_s3_bucket_object" "bootstrap" {
  bucket = "${var.rpm_bucket}"
  key    = "${var.rpm_prefix}/bootstrap.sh"
  source = "./bootstrap.sh"
  etag   = "${md5(file("./bootstrap.sh"))}"
}
