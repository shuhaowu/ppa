#!/bin/bash

set -e

DEFAULT_PPA_ID=shuhao/fixed

project=$1
ppa_id=$2

if [ -z $project ]; then
  >&2 echo "usage: ./release-to-ppa.sh project [ppa_id]"
  exit 1
fi

if [ -z $ppa_id ]; then
  ppa_id=$DEFAULT_PPA_ID
fi

source setup-build.sh $project

pushd $project_build_dir >/dev/null
  tar czf ${project_version}.orig.tar.gz $project_version
  pushd $project_version >/dev/null
    debuild -S -sa
  popd >/dev/null
  dput ppa:$ppa_id ${project_version}*.changes
popd >/dev/null
