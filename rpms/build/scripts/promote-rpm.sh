#!/bin/bash
set -e
if [ ! -z "${DEBUG}" ]; then
  set -x
fi

while getopts "s:t:r:" opt; do
  case $opt in
    r) RPM_MATCH=$OPTARG ;;
    s) SOURCE_BUCKET=$OPTARG ;;
    t) TARGET_BUCKET=$OPTARG ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

die() { echo "$*" 1>&2 ; exit 1; }
[ -z "${RPM_MATCH}" ] || die "RPM_MATCH string must be specifie."
[ -z "${SOURCE_BUCKET}" ] || die "SOURCE_BUCKET must be specified"
[ -z "${TARGET_BUCKET}" ] || die "TARGET_BUCKET must be specified"

SOURCE_DIR="/tmp/${SOURCE_BUCKET}"
TARGET_DIR="/tmp/${TARGET_BUCKET}"

mkdir -p $SOURCE_DIR
mkdir -p $TARGET_DIR
aws s3 sync "s3://${SOURCE_BUCKET}" $SOURCE_DIR
aws s3 sync "s3://${TARGET_BUCKET}" $TARGET_DIR

# copy the RPMs to target directory
mkdir -pv $TARGET_DIR/x86_64/
cp -rv $SOURCE_DIR/x86_64/$RPM_MATCH-1.x86_64.rpm $TARGET_DIR/x86_64/

# optionally update the target RPM repo
if [ -e "${TARGET_DIR}/noarch/repodata/repomd.xml" ]; then
  UPDATE="--update "
else
  UPDATE=""
fi
for a in $TARGET_DIR/x86_64 ; do createrepo -v $UPDATE --deltas $a/ ; done

aws s3 sync $TARGET_DIR s3://$TARGET_BUCKET