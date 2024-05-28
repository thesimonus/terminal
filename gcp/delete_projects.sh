#!/bin/bash

if [ "$#" -lt 1 ]; then
   echo "Usage:  ./delete_projects.sh PROJECT_ID"
   echo "   eg:  ./create_projects.sh dev-6666 "
   exit
fi

gcloud components update
gcloud components install alpha

PROJECT_ID=$1

echo -e "\nDeleting project $PROJECT_ID ... \n"

gcloud alpha projects delete $PROJECT_ID

# unlink billing account

echo -e "\nUnlink project $PROJECT_ID from billing account ... \n"

gcloud beta billing projects unlink $PROJECT_ID 

# if [ "$#" -lt 2 ]; then
#    echo "Usage:  ./create_projects.sh  project-prefix  email1 [email2 [email3 ...]]]"
#    echo "   eg:  ./create_projects.sh  learnml-20170106  somebody@gmail.com someother@gmail.com"
#    exit
# fi

# gcloud components update
# gcloud components install alpha

# PROJECT_PREFIX=$1
# shift
# EMAILS=$@

# for EMAIL in $EMAILS; do
#    PROJECT_ID=$(echo "${PROJECT_PREFIX}-${EMAIL}" | sed 's/@/x/g' | sed 's/\./x/g' | cut -c 1-30)
#    echo "Deleting project $PROJECT_ID for $EMAIL ... "

#    gcloud alpha projects delete $PROJECT_ID
# done
