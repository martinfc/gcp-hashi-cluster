#!/bin/bash


# validate working directory is: $REPO_DIRECTORY/operations/
WORKING_DIRECTORY=$(readlink --canonicalize ".")

if [[ $WORKING_DIRECTORY != *operations && $WORKING_DIRECTORY != *operations/ ]]; then
  echo "error: working directory must be 'gcp-hashi-cluster/operations/'"; exit 1
fi


REPO_DIRECTORY=$(readlink --canonicalize ..)
PROJECT_INFO=$(cat "$REPO_DIRECTORY/build/conf/project-info.json")
CLUSTER_PROJECT_ID=$(echo $PROJECT_INFO | jq -r ".cluster_service_project_id")
CLUSTER_PROJECT_TF_SA_SSH_PRIVATE_KEY_FILE=$(echo $PROJECT_INFO | jq -r ".cluster_tf_service_account_ssh_private_key_filepath")

FILEPATH=$1

if [ ! -f $FILEPATH ]; then
    echo "error: $FILEPATH doesn't exist"; exit 1
fi

FILENAME=$(echo $FILEPATH | grep -o '[^/]*$')


get_instance_zone () {
  INSTANCE_ZONE=$(gcloud compute instances list --filter="name:$1" --project=$CLUSTER_PROJECT_ID --format="value(ZONE)" --limit=1)
  if [[ -z $INSTANCE_ZONE ]]; then
    echo "no instance $1 found"; exit 1
  fi
  echo $INSTANCE_ZONE
}


# arguments 2, 3, 4 etc are GCP instance names
for INSTANCE_NAME in "${@:2}"
do
  echo "uploading $FILEPATH to: $INSTANCE_NAME"

  INSTANCE_ZONE=$(get_instance_zone $INSTANCE_NAME)

  gcloud compute scp $FILEPATH \
      "$INSTANCE_NAME:/tmp/$FILENAME" \
      --project $CLUSTER_PROJECT_ID \
      --zone $INSTANCE_ZONE \
      --tunnel-through-iap \
      --ssh-key-file=$CLUSTER_PROJECT_TF_SA_SSH_PRIVATE_KEY_FILE
done