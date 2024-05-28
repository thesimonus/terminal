#!/bin/zsh
  for project in  $(gcloud projects list --format="value(projectId)")
       do
         for api in $(gcloud services list --enabled --project $project --format='value(NAME)')
           do
             echo "${project},${api}"
           done 
       done