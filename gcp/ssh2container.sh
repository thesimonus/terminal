#!/bin/bash

PROJECT_ID=$1
INSTANCE_NAME=$2

echo -e "\nGetting ZONE for $INSTANCE_NAME ..."

ZONE=`gcloud compute instances list --filter="NAME=$INSTANCES_NAME" --format="value(ZONE)"`
ZONE=${ZONE//[[:space:]]/}

echo -e "\nssh to $INSTANCE_NAME at zone $ZONE ...\n"

gcloud compute ssh $INSTANCE_NAME \
  --zone $ZONE \
  --project=$PROJECT_ID  \
  --container=$(gcloud compute ssh $INSTANCE_NAME --project=$PROJECT_ID --zone=$ZONE --command 'zsh')

