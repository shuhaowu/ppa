#!/bin/bash

project=$1

if [ -z $project ]; then
  >&2 echo "usage: ./build-deb.sh directory [ppa_id]"
  exit 1
fi

source setup-build.sh $project

pushd $project_build_dir >/dev/null
  tar czf ${project_version}.orig.tar.gz $project_version
  pushd $project_version >/dev/null
    debuild
  popd >/dev/null
popd >/dev/null
