#!/bin/bash

VERSION=$1 #Version
BRANCH=$2
MESSAGE="0"
DRAFT="true"
PRE="true"
TOKEN="$(cat git-token.txt | openssl enc -aes-256-cbc -md sha512 -a -d -pbkdf2 -iter 100000 -salt -pass pass:Secret@123#)"
REPO_OWNER="RohitBavkar"
REPO_NAME="sas-client"
GITHUB="https://api.github.com"

# set default message
if [ "$MESSAGE" == "0" ]; then
	MESSAGE=$(printf "Release of version %s" $VERSION)
fi

API_JSON=$(printf '{"tag_name": "v%s","target_commitish": "%s","name": "v%s","body": "%s","draft": %s,"prerelease": %s}' "$VERSION" "$BRANCH" "$VERSION" "$MESSAGE" "$DRAFT" "$PRE" )
API_RESPONSE_STATUS=$(curl --data "$API_JSON" -s -i $GITHUB/repos/$REPO_OWNER/$REPO_NAME/releases?access_token=$TOKEN)
echo "$API_RESPONSE_STATUS"