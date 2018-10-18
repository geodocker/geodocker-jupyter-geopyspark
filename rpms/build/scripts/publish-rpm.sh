#!/bin/bash
set -e
if [ ! -z "${DEBUG}" ]; then
  set -x
fi

while getopts "s:t:" opt; do
  case $opt in
    s) SOURCE_DIR=$OPTARG ;;
    t) TARGET_BUCKET=$OPTARG ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

die() { echo "$*" 1>&2 ; exit 1; }
[ -z "${SOURCE_DIR}" ] || die "SOURCE_DIR must be specified"
[ -z "${TARGET_BUCKET}" ] || die "TARGET_BUCKET must be specified"

echo "Publishing RPMS from $SOURCE_DIR to s3://$TARGET_BUCKET"

TMP_DIR="/tmp/${TARGET_BUCKET}"

mkdir -pv $TMP_DIR/x86_64/
aws s3 sync "s3://${TARGET_BUCKET}" $TMP_DIR

cp -rv $SOURCE_DIR/RPMS/* $TMP_DIR/x86_64/
if [ -e "$TMP_DIR/x86_64/repodata/repomd.xml" ]; then
  UPDATE="--update "
else
  UPDATE=""
fi
for a in $TMP_DIR/x86_64 ; do createrepo -v $UPDATE --deltas $a/ ; done

aws s3 sync $TMP_DIR s3://$TARGET_BUCKET
