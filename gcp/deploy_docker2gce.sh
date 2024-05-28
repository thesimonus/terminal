#!/bin/bash

PROJECT_ID=$1
INSTANCES_ID=$2


# Enable gcloud services
# gcloud services enable \
#   logging.googleapis.com \
#   compute.googleapis.com \
#   cloudbuild.googleapis.com \
#   secretmanager.googleapis.com \
#   artifactregistry.googleapis.com
# container registry

# Build docker
# docker build -t $INSTANCES_ID .



# docker tag $INSTANCES_ID gcr.io/$PROJECT_ID/$INSTANCES_ID

# Authentication: Adding credentials for all GCR repositories allow to push image to Artifact Registry
# gcloud auth configure-docker

# Push image to Artifact Registry
# docker push gcr.io/$PROJECT_ID/$INSTANCES_ID

