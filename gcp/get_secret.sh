#!/bin/bash

if [ "$#" -eq 2 ]; then
    PROJECT_ID=$1
    SECRET_NAME=$2
    SECRET_VERSION="latest"
elif [ "$#" -eq 3 ]; then
    PROJECT_ID=$1
    SECRET_NAME=$2
    SECRET_VERSION=$3
else
   echo "Usage:  ./get_secret.sh PROJECT_ID SECRET_NAME SECRET_VERSION"
   echo "   eg:  ./get_secret.sh dev-6666 ssh-key-public 2"
   exit
fi

# Enable gcloud services
echo -e "\nSet default project to $PROJECT_ID ..."
gcloud config set project $PROJECT_ID

# Access a secret version:
echo -e "\nGetting the secret $SECRET_NAME version $SECRET_VERSION on project $PROJECT_ID\n"
SECRET=`gcloud secrets versions access $SECRET_VERSION --secret=$SECRET_NAME`
echo $SECRET
echo $SECRET > .$SECRET_NAME