#!/bin/bash

if [ "$#" -lt 3 ]; then
   echo "Usage:  ./deploy_docker2gce.sh PROJECT_ID APP_NAME ZONE"
   echo "   eg:  ./deploy_docker2gce.sh dev-6666 demo us-central1-a"
   exit
fi

# Set values
# ZONE=us-central1-a
MACHINE_TYPE=e2-small
IMAGE_PROJECT=ubuntu-os-cloud
IMAGE_FAMILY=ubuntu-2004-lts
CONTAINER_ENV_FILE=/Users/henry/Drive/Projects/Dev/prjqb/.env

PROJECT_ID=$1
IMAGE_NAME=$2-image
ZONE=$3

# Enable gcloud services
echo -e "\nEnabling gcloud services on project ${PROJECT_ID}: \
  \ncompute.googleapis.com \
  \nlogging.googleapis.com \
  \nartifactregistry.googleapis.com \
  \n"

gcloud services enable \
  compute.googleapis.com \
  logging.googleapis.com \
  artifactregistry.googleapis.com \
  --project=$PROJECT_ID

# gcloud services enable \
#   logging.googleapis.com \
#   compute.googleapis.com \
#   cloudbuild.googleapis.com \
#   secretmanager.googleapis.com \
#   artifactregistry.googleapis.com
  # containerregistry.googleapis.com \


# Build docker
echo -e "\nBuilding docker image $IMAGE_NAME\n"
docker build -t $IMAGE_NAME .

# tag
echo -e "\ntag docker $IMAGE_NAME gcr.io/$PROJECT_ID/$IMAGE_NAME\n"
docker tag $IMAGE_NAME gcr.io/$PROJECT_ID/$IMAGE_NAME

# Authentication: Adding credentials for all GCR repositories allow to push image to Artifact Registry
gcloud auth configure-docker

# Push image to Artifact Registry
echo -e "Pushing image $IMAGE_NAME to Artifact Registry at gcr.io/$PROJECT_ID/$IMAGE_NAME\n"
docker push gcr.io/$PROJECT_ID/$IMAGE_NAME

# Create instance
echo -e "\nCreating compute instances with container: \
  \n--project=$PROJECT_ID \
  \n--zone=$ZONE \
  \n--machine-type=$MACHINE_TYPE\
  \n--image-project=$IMAGE_PROJECT \
  \n--image-family=$IMAGE_FAMILY \
  \n--container-image=gcr.io/$PROJECT_ID/$IMAGE_NAME:latest \
  \n--container-env-file=$CONTAINER_ENV_FILE 
  \n"

gcloud compute instances create-with-container $IMAGE_NAME \
    --project=$PROJECT_ID \
    --zone=$ZONE \
    --machine-type=$MACHINE_TYPE\
    --image-project=$IMAGE_PROJECT \
    --image-family=$IMAGE_FAMILY \
    --container-image=gcr.io/$PROJECT_ID/$IMAGE_NAME:latest \
    --container-env-file=$CONTAINER_ENV_FILE 


