#!/bin/bash
tag=$1 
BRANCH=$2
github_api_token="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"
owner="RohitBavkar"
MODULE="sas-client"
repo=$MODULE #Repo
BUILD_PATH="$(pwd)"
filename="$MODULE-$tag.zip" #Filename with path
filename_path="$BUILD_PATH/$MODULE-$tag.zip" #Filename with path

#aws s3 cp $filename_path s3://s3-artifacts-uai3023022-us8p/RohitBavkar/releases/$BRANCH/ --sse aws:kms --sse-kms-key-id 57bf1edb-df98-4fec-9ff4-07094435ee07