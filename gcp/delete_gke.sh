#!/bin/bash

if [ "$#" -lt 3 ]; then
   echo "Usage:  ./create_gke.sh PROJECT_ID GKE_NAME REGION"
   echo "   eg:  ./create_gke.sh prjvcp-2 gke-test us-central1"
   exit
fi

PROJECT_ID=$1
GKE_NAME=$2
REGION=$3
# NODE=$4

# Set the default project, zone, region
gcloud config set project $PROJECT_ID
# # gcloud config set compute/zone $ZONE
# gcloud config set compute/region $REGION

# Delete GKE cluster
echo -e "\nDeleting GKE cluster $GKE_NAME at region $REGION ...\n"
gcloud container clusters delete $GKE_NAME \
  --region=$REGION
