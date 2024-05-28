#!/bin/bash

if [ "$#" -lt 2 ]; then
   echo "Usage:  ./delete_instance.sh PROJECT_ID INSTANCES_NAME"
   echo "   eg:  ./delete_instance.sh dev-6666 instance-1"
   exit
fi

PROJECT_ID=$1
INSTANCES_NAME=$2

# get the current working project 
PROJECT_CURRENT=`gcloud config get-value project`

if [ "$PROJECT_ID" != "$PROJECT_CURRENT" ]; then
    echo -e "\nThe default project is $PROJECT_CURRENT \
            \nSetting project to $PROJECT_ID ...\n"
    # set working project to PROJECT_ID
    gcloud config set project $PROJECT_ID
fi

# get ZONE
echo -e "\nGetting ZONE for $INSTANCES_NAME ..."

ZONE=`gcloud compute instances list --filter="NAME=$INSTANCES_NAME" --format="value(ZONE)"`
ZONE=${ZONE//[[:space:]]/}

# Delete the compute instance
echo -e "\nDeleting compute instance $INSTANCES_NAME at Zone $ZONE ...\n"
gcloud compute instances delete $INSTANCES_NAME --zone=$ZONE

# set back to the working project
echo -e "\nSetting default project to $PROJECT_CURRENT ...\n"

gcloud config set project $PROJECT_CURRENT
