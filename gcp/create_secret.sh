#!/bin/bash

if [ "$#" -lt 3 ]; then
   echo "Usage:  ./create_secret.sh PROJECT_ID SECRET_NAME SECRET (file or text)"
   echo "   eg:  ./create_secret.sh dev-6666 ssh-key-public ~/Drive/Personal/Henry/ssh_key/henry_ed25519_gcp.pub"
   exit
fi

PROJECT_ID=$1
SECRET_NAME=$2
SECRET=$3

# Enable gcloud services
echo -e "\nEnabling Compute Engine service on project $PROJECT_ID..\n"

gcloud config set project $PROJECT_ID
gcloud services enable \
  secretmanager.googleapis.com 

# Creating a secret
echo -e "\nCreating a secret $SECRET_NAME on project $PROJECT_ID\n"
gcloud secrets create $SECRET_NAME \
    --replication-policy="automatic"

if [[ -d $SECRET ]]; then
    echo -e "\n$SECRET is a directory, it will be added to the the Secret $SECRET_NAME as a text string"
    echo -n $SECRET | \
        gcloud secrets versions add $SECRET_NAME --data-file=-
elif [[ -f $SECRET ]]; then
    echo -e "\n$SECRET is a file, the content of the file will be added to the the Secret $SECRET_NAME"
    gcloud secrets versions add $SECRET_NAME --data-file=$SECRET
else
    echo -e "$SECRET is text, it will be added to the the Secret $SECRET_NAME as a text string"
    echo -n $SECRET | \
    gcloud secrets versions add $SECRET_NAME --data-file=-
fi
