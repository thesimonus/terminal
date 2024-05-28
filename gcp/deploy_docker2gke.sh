#!/bin/bash

if [ "$#" -lt 3 ]; then
   echo "Usage:  ./deploy_docker2gke.sh PROJECT_ID GKE_NAME APP_NAME"
   echo "   eg:  ./deploy_docker2gke.sh dev-6666 gke_us prjqb"
   exit
fi

PROJECT_ID=$1
GKE_NAME=$2
APP_NAME=$3

# Enable gcloud services
echo -e "\nEnabling gcloud services on project $PROJECT_ID: \
    \ncloudbuild.googleapis.com \
    \nartifactregistry.googleapis.com \
    \nsecretmanager.googleapis.com \
    \nlogging.googleapis.com 
    \n"

# gcloud config set project $PROJECT_ID

gcloud services enable \
    cloudbuild.googleapis.com \
    artifactregistry.googleapis.com \
    secretmanager.googleapis.com \
    logging.googleapis.com \
    --project=$PROJECT_ID

# Authentication: Adding credentials for all GCR repositories allow to push image to Artifact Registry
gcloud auth configure-docker

# Build and Publish Container Images
echo -e "\nBuild docker image $APP_NAME-image and push to Artifact Registry at gcr.io/$PROJECT_ID/$APP_NAME-image ...\n"

# gcloud builds submit --tag gcr.io/$PROJECT_ID/$APP_NAME-image .
gcloud builds submit \
    --project=$PROJECT_ID \
    --config docker-compose.yml \
    --tag gcr.io/$PROJECT_ID/$APP_NAME-image .

# docker build -t gcr.io/$PROJECT_ID/$APP_NAME-image:v0.1 .
# docker push gcr.io/$PROJECT_ID/$APP_NAME-image:v0.1



# Create the Deployment
echo -e "\nDeploy image gcr.io/$PROJECT_ID/$APP_NAME-image to GKE cluster $GKE_NAME ...\n"
kubectl create deployment $GKE_NAME \
    --image=gcr.io/$PROJECT_ID/$APP_NAME-image

# Expose the Deployment
kubectl expose deployment $GKE_NAME \
    --type LoadBalancer --port 443 --target-port 8000