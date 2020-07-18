#!/bin/bash

WORKING_DIRECTORY=$(readlink --canonicalize ".")

if [[ "$WORKING_DIRECTORY" != *build && "$WORKING_DIRECTORY" != *build/ ]]; then
  echo "error: working directory must be 'gcp-hashi-cluster/build/'"
  exit 1
fi

export REPO_DIRECTORY=$(readlink --canonicalize ..)

VARS_FILEPATH="$REPO_DIRECTORY/build/conf/project-info.json"

cd "$REPO_DIRECTORY/infrastructure/cluster-nodes"

# delete any previous Terraform state
rm -rf ".terraform"
rm -f "terraform.tfstate"
rm -f "terraform.tfstate.backup"

terraform init

terraform apply -auto-approve -var-file=$VARS_FILEPATH
