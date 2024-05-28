#!/bin/bash

if [ "$#" -lt 2 ]; then
   echo "Usage:  ./create_instance.sh PROJECT_ID INSTANCES_NAME"
   echo "   eg:  ./create_instance.sh dev-6666 instance-1"
   exit
fi

# Set values
MACHINE_TYPE=t2a-standard-1
IMAGE_PROJECT=ubuntu-os-cloud
IMAGE_FAMILY=ubuntu-2204-lts-arm64
SSH_KEY_PUB=ssh-key-heny-pub-gcp
SSH_KEY_PRIVATE=ssh-key-heny
SETUP_ZSH=./setup_zsh.sh
# ZONE="us-central1-b"

PROJECT_ID=$1
INSTANCES_NAME=$2

# get default ZONE
ZONE=`gcloud config get-value compute/zone`

# get REGION
# REGION=`gcloud config get-value compute/region`

# Enable Compute Engine
echo -e "\nEnabling Compute Engine service on project $PROJECT_ID..\n"
gcloud services enable \
  compute.googleapis.com \
  secretmanager.googleapis.com 

# Access a secret 
gcloud config set project $PROJECT_ID
SSH_KEY=`gcloud secrets versions access latest --secret=$SSH_KEY_PUB`

# Create instance
echo -e "\nCreating Compute instance $INSTANCES_NAME ...\
  \n--project=$PROJECT_ID \
  \n--zone=$ZONE \
  \n--machine-type=$MACHINE_TYPE\
  \n--image-project=$IMAGE_PROJECT \
  \n--image-family=$IMAGE_FAMILY \
  \n--network-interface=nic-type=GVNIC \
  \n"

gcloud compute instances create $INSTANCES_NAME \
  --project=$PROJECT_ID \
  --zone=$ZONE \
  --machine-type=$MACHINE_TYPE\
  --image-project=$IMAGE_PROJECT \
  --image-family=$IMAGE_FAMILY \
  --network-interface=nic-type=GVNIC

# Add SSH key to the instance: use secret manager
echo -e "\nadd ssh-key public to the $INSTANCES_NAME ...\
  \nssh-key from secret manager: $SSH_KEY_PUB \
  \n"

SSH_KEY=`gcloud secrets versions access latest --secret=$SSH_KEY_PUB`
gcloud compute instances add-metadata $INSTANCES_NAME \
  --zone=$ZONE \
  --metadata=ssh-keys="$SSH_KEY"

echo -e "\nOpen https-server,http-server on $INSTANCES_NAME ..."
gcloud compute instances add-tags $INSTANCES_NAME \
  --zone=$ZONE \
  --tags=https-server,http-server

# Add SSH key to the instance: use local key file
# gcloud compute instances add-metadata $INSTANCES_NAME \
#   --zone=$ZONE \
#   --metadata-from-file=ssh-keys=$SSH_KEY_PUB 

# Download ssh-key private from google secret 
echo -e "\nadd ssh-key private to the $INSTANCES_NAME ...\
  \nssh-key from secret manager: $SSH_KEY_PRIVATE \
  \n"
SSH_KEY=`gcloud secrets versions access latest --secret=$SSH_KEY_PRIVATE`
printf "%s\n" "$SSH_KEY">.$SSH_KEY_PRIVATE

# Check and wait until instance up then push files over scp then remote execute 
echo -e "\nWait until instance up then push files over scp then remote execute ..."

# Check and wait until instance up then push file over scp then remote execute 
IP=`gcloud compute instances list \
  --project=$PROJECT_ID \
  --filter="name=$INSTANCES_NAME" \
  --format="value(EXTERNAL_IP)"`

SECONDS=0
until nc -w 1 -z $IP 22
do
  if [ $SECONDS -eq 60 ]; then
    echo "Something is not right, check the process of creating instance ..."
    exit 1
  else
    echo "SSH is not up yet. Waiting..."
    sleep 5
  fi
done

# Push ssh-key private to the instance
gcloud compute scp .$SSH_KEY_PRIVATE $INSTANCES_NAME:~/.ssh/.ssh-key
rm .$SSH_KEY_PRIVATE

# Setup ohmyzsh
echo -e "\nPushing $SETUP_ZSH to $INSTANCES_NAME:~/setup_zsh.sh ..."
gcloud compute scp $SETUP_ZSH $INSTANCES_NAME:~/setup_zsh.sh

echo -e "\nSetting up Oh My ZSH on $INSTANCES_NAME ..."
gcloud compute ssh $INSTANCES_NAME  \
  --zone $ZONE \
  --command 'chmod +x ~/setup_zsh.sh && sh ~/setup_zsh.sh'
  