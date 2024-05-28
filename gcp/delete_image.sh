#!/bin/bash

PROJECT_ID=$1
IMAGE_NAME=$2
HOSTNAME=gcr.io

echo -e "\nList all images on project $PROJECT_ID at $HOSTNAME ...\n"
gcloud container images list 

echo -e "\nDeleting image $IMAGE_NAME on project $PROJECT_ID at $HOSTNAME ...\n"
gcloud container images delete $HOSTNAME/$PROJECT_ID/$IMAGE_NAME
