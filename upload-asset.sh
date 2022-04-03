#!/bin/bash
tag=$1 #Version
BRANCH=$2
repo="sas-client"
GH_API="https://github.com/"
owner="RohitBavkar"
TOKEN="$(cat git-token.txt | openssl enc -aes-256-cbc -md sha512 -a -d -pbkdf2 -iter 100000 -salt -pass pass:Secret@123#)"
GH_REPO="$GH_API/repos/$owner/$repo"
GH_TAGS="$GH_REPO/releases/tags/$tag"
AUTH="Authorization: token $TOKEN"
WGET_ARGS="--content-disposition --auth-no-challenge --no-cookie"
BUILD_PATH="$(pwd)"
filename="$MODULE-$tag.zip" #Filename with path
filename_path="$BUILD_PATH/$MODULE-$tag.zip" #Filename with path

#Validate token.
curl -o /dev/null -sH "$AUTH" $GH_REPO || { echo "Error: Invalid repo, token or network issue!";  exit 1; }

#Read asset tags.
response=$(curl -sH "$AUTH" $GH_TAGS)

echo response;

#Get ID of the asset based on given filename.
eval $(echo "$response" | grep -m 1 "id.:" | grep -w id | tr : = | tr -cd '[[:alnum:]]=')
[ "$id" ] || { echo "Error: Failed to get release id for tag: $tag"; echo "$response" | awk 'length($0)<100' >&2; exit 1; }

#Upload asset
echo "Uploading asset... $localAssetPath" >&2

#Construct url
GH_ASSET="https://github.build.ge.com/api/uploads/repos/$owner/$repo/releases/$id/assets?name=$(basename $filename)"

curl --data-binary @"$filename_path" -H "Authorization: token $TOKEN" -H "Content-Type: application/octet-stream" $GH_ASSET
