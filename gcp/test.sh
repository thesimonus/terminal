#!/bin/sh

PROJECT_ID=dev-6666
INSTANCES_NAME=prjqb
ZONE=us-central1-b
SSH_KEY_PUB=ssh-key-heny-pub-gcp
SSH_KEY_PRIVATE=ssh-key-heny

gcloud config set project $PROJECT_ID
SSH_KEY=`gcloud secrets versions access latest --secret=$SSH_KEY_PRIVATE`
printf "%s\n" "$SSH_KEY">.$SSH_KEY_PRIVATE

gcloud compute scp .$SSH_KEY_PRIVATE $INSTANCES_NAME:~/.ssh/.ssh-key


gcloud compute ssh $INSTANCES_NAME \
  --zone $ZONE \
  --command 'eval "$(ssh-agent -s)" && chmod 600 ~/.ssh/.ssh-key && ssh-add ~/.ssh/.ssh-key' 