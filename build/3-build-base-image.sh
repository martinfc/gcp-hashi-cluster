#!/bin/bash

WORKING_DIRECTORY=$(readlink --canonicalize ".")

if [[ "$WORKING_DIRECTORY" != *build && "$WORKING_DIRECTORY" != *build/ ]]; then
  echo "error: working directory must be 'gcp-hashi-cluster/build/'"
  exit 1
fi

export REPO_DIRECTORY=$(readlink --canonicalize ..)

VARS_FILEPATH="$REPO_DIRECTORY/build/conf/project-info.json"


# packer build should be run here (ssh key file paths are relative to this)
cd "$REPO_DIRECTORY/build/vm_images"


#export PACKER_LOG=1

packer build -var-file=$VARS_FILEPATH hashi_base.pkr.hcl
