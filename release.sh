#!/bin/bash

set -e

DEFAULT_PPA_ID=shuhao/fixed

ORIG_DIR=orig
DEBIAN_DIR=debian
BUILD_DIR=_build

project=$1
ppa_id=$2
version=$3

if [ -z $project ]; then
  >&2 echo "usage: ./release.sh directory [ppa_id] [version]"
  exit 1
fi

project_orig_dir=$ORIG_DIR/$project
project_debian_dir=$DEBIAN_DIR/$project/debian
project_build_dir=$BUILD_DIR/$project

if [ ! -d $project_orig_dir ]; then
  >&2 echo "ERROR: $project_orig_dir does not exist"
  exit 1
fi

if [ -z $ppa_id ]; then
  ppa_id=$DEFAULT_PPA_ID
fi

if [ -z $version ]; then
  pushd $project_debian_dir/.. >/dev/null
    version=`dpkg-parsechangelog --show-field Version | cut -f 2 -d ":" | cut -f 1 -d "-"`
  popd >/dev/null
fi

project_version="${project}_${version}"
echo "Performing a release of $project_version"

set -x

rm -rf $project_build_dir
mkdir -p $project_build_dir/$project_version

pushd $project_orig_dir >/dev/null
  git checkout-index -a -f --prefix="../../$project_build_dir/$project_version/"
popd >/dev/null

cp -ar $project_debian_dir $project_build_dir/$project_version

pushd $project_build_dir >/dev/null
  tar czf ${project_version}.orig.tar.gz $project_version
  pushd $project_version >/dev/null
    debuild -S -sa
  popd >/dev/null
  dput ppa:$ppa_id ${project}*.changes
popd >/dev/null
