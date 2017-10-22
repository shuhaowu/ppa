#!/bin/bash

set -e

project=$1

ORIG_DIR=orig
DEBIAN_DIR=debian
BUILD_DIR=_build

project_orig_dir=$ORIG_DIR/$project
project_debian_dir=$DEBIAN_DIR/$project/debian
project_build_dir=$BUILD_DIR/$project

if [ ! -d $project_orig_dir ]; then
  >&2 echo "ERROR: $project_orig_dir does not exist"
  exit 1
fi

if [ ! -d $project_debian_dir ]; then
  >&2 echo "ERROR: $project_debian_dir does not exist"
  exit 1
fi

pushd $project_debian_dir/.. >/dev/null
  version=`dpkg-parsechangelog --show-field Version | cut -f 2 -d ":" | cut -f 1 -d "-"`
popd >/dev/null

project_version="${project}_${version}"
echo "Setting up build of $project_version"

set -x

rm -rf $project_build_dir/$project_version
mkdir -p $project_build_dir/$project_version

pushd $project_orig_dir >/dev/null
  git checkout-index -a -f --prefix="../../$project_build_dir/$project_version/"
popd >/dev/null

cp -ar $project_debian_dir $project_build_dir/$project_version
