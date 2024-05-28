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
# gcloud config set compute/zone $ZONE
gcloud config set compute/region $REGION

# Enable Compute Engine
echo -e "\nEnabling gcloud service on project $PROJECT_ID ...\n"
gcloud services enable \
  container.googleapis.com

# Create an Autopilot GKE cluster
echo -e "\nCreating an Autopilot GKE cluster on project $PROJECT_ID region=$REGION...\n"

gcloud container clusters create-auto $GKE_NAME \
  --region=$REGION

# # Create an Standard GKE cluster
# gcloud container clusters create $GKE_NAME \
#     --num-nodes=$NODE \
#     --zone=$ZONE


# Get authentication credentials for the cluster
echo -e "\nEGet authentication credentials for the GKE cluster $GKE_NAME at region $REGION ...\n"
gcloud container clusters get-credentials $GKE_NAME \
  --region=$REGION
