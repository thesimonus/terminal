#!/bin/bash

if [ "$#" -lt 2 ]; then
   echo "Usage:  ./create_projects.sh PROJECT_ID SERVICE_ACCOUNT_ID"
   echo "   eg:  ./create_projects.sh dev-6666 henry"
   exit
fi

PROJECT_ID=$1
SERVICE_ACCOUNT_ID=$2
# get the ACTIVE  ACCOUNT 
GPC_ACTIVE_ACCOUNT=`gcloud config get-value account`

# get BILLING ACCOUNT_ID
GCP_BILLING_ACCOUNT_ID=`gcloud alpha billing accounts list --format="value(ACCOUNT_ID)"`
# GCP_BILLING_ACCOUNT_ID=$(echo -e "$GCP_BILLING_ACCOUNT_ID" | tail -1)
# GCP_BILLING_ACCOUNT_ID=${GCP_BILLING_ACCOUNT_ID%% *}
# GCP_BILLING_ACCOUNT_ID=${GCP_BILLING_ACCOUNT_ID//[[:space:]]/}

gcloud components update
gcloud components install alpha

# Create project
echo -e "\nActive Account: $GPC_ACTIVE_ACCOUNT, Billing Account ID: $GCP_BILLING_ACCOUNT_ID \n\nCreating Project: $PROJECT_ID ..."
# create
gcloud alpha projects create $PROJECT_ID
sleep 2

# billing
echo -e "\nLink $PROJECT_ID to the billing account $GCP_BILLING_ACCOUNT_ID\n"
gcloud beta billing projects link $PROJECT_ID --billing-account=$GCP_BILLING_ACCOUNT_ID

# # editor
# rm -f iam.json.*
# gcloud alpha projects get-iam-policy $PROJECT_ID --format=json > iam.json.orig
# cat iam.json.orig | sed s'/"bindings": \[/"bindings": \[ \{"members": \["user:'$EMAIL'"\],"role": "roles\/editor"\},/g' > iam.json.new
# gcloud alpha projects set-iam-policy $PROJECT_ID iam.json.new

# Enable gcloud services
gcloud config set project $PROJECT_ID
gcloud services enable \
  iam.googleapis.com 

# create the service account
echo -e "\nCreating service account $SERVICE_ACCOUNT_ID@$PROJECT_ID.iam.gserviceaccount.com for project $PROJECT_ID\n"

gcloud iam service-accounts create $SERVICE_ACCOUNT_ID \
    --description="Service account for project $PROJECT_ID" \
    --display-name="$SERVICE_ACCOUNT_ID"

# grant service account an IAM role on the project
echo -e "\nGrant $SERVICE_ACCOUNT_ID@$PROJECT_ID.iam.gserviceaccount.com as the owner roles on the project $PROJECT_ID\n"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_ID@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/owner"

# Create a service account key
echo -e "\nCreate a service account key for $SERVICE_ACCOUNT_ID@$PROJECT_ID.iam.gserviceaccount.com\n"
gcloud iam service-accounts keys create "$SERVICE_ACCOUNT_ID@$PROJECT_ID.iam.gserviceaccount.com.json" \
    --iam-account=$SERVICE_ACCOUNT_ID@$PROJECT_ID.iam.gserviceaccount.com
