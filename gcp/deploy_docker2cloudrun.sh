#!/bin/bash

if [ "$#" -lt 3 ]; then
   echo "Usage:  ./deploy_docker2cloudrun.sh PROJECT_ID APP_NAME REGION"
   echo "   eg:  ./deploy_docker2cloudrun.sh dev-6666 demo us-central1"
   exit
fi

PROJECT_ID=$1
APP_NAME=$2
REGION=$3


# Enable gcloud services
echo -e "\nEnabling gcloud services on project ${PROJECT_ID}: \
    \ncloudbuild.googleapis.com \
    \nrun.googleapis.com \
    \nartifactregistry.googleapis.com \
    \nsecretmanager.googleapis.com \
    \nlogging.googleapis.com 
    \n"

gcloud config set project $PROJECT_ID

gcloud services enable \
    cloudbuild.googleapis.com \
    run.googleapis.com \
    artifactregistry.googleapis.com \
    secretmanager.googleapis.com \
    logging.googleapis.com 

# Authentication: Adding credentials for all GCR repositories allow to push image to Artifact Registry
gcloud auth configure-docker

# Build and Publish Container Images
echo -e "\nBuild docker image $APP_NAME-image and push to Artifact Registry at gcr.io/$PROJECT_ID/$APP_NAME-image ...\n"

gcloud builds submit --tag gcr.io/$PROJECT_ID/$APP_NAME-image .

# Deploy to Cloud Run
echo -e "\nDeploy image gcr.io/$PROJECT_ID/$APP_NAME-image to Cloud Run ...\n"

gcloud run deploy $APP_NAME-app \
    --image gcr.io/$PROJECT_ID/$APP_NAME-image \
    --region $REGION \
    --platform managed \
    --allow-unauthenticated --quiet
