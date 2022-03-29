#!/bin/bash
VERSION=""
BRANCH="$1"
RELEASE_NOTES="$2"
BUILD_PATH="$(pwd)"
MODULE="sas-client"
TOKEN="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"
REPO="RohitBavkar/$MODULE"
GITHUB="https://github.com/"

# checkout branch
echo "[INFO] Executing build from directory $(pwd)"
echo "$(git checkout $BRANCH)"

# Version bump and tag
npm version minor -m "[skip-ci] Incremented version to %s"

echo "Running build..."
sh build.sh
echo "Build completed"

VERSION=$(node -pe "require('./package.json').version")

git push https://$TOKEN@github.com/$REPO.git $BRANCH
git push https://$TOKEN@github.com/$REPO.git refs/tags/$VERSION

set +e
git push https://$TOKEN@github.com/$REPO.git :refs/tags/Development
git tag -d Development
set -e
git tag -m "[skip-ci] Development tag" Development
git push https://$TOKEN@github.com/$REPO.git refs/tags/Development


echo "Package build as zip file..."
jar -cfM sas-client-$VERSION.zip dist

sleep 2

GIT_HUB_RELEASE_URL="curl -i -g -X POST $GITHUB/$REPO/releases -H 'authorization: token $TOKEN' -H 'cache-control: no-cache' -H 'content-type: application/json' -d '{\"tag_name\": \"$VERSION\",\"target_commitish\": \"$BRANCH\",\"name\": \"$VERSION\",\"body\": \"$RELEASE_NOTES\",\"draft\": false,\"prerelease\": true}'"
echo $GIT_HUB_RELEASE_URL
eval "$GIT_HUB_RELEASE_URL"

# Get release id
GIT_HUB_RELEASE_DETAILS_URL="curl -X GET $GITHUB/$REPO/releases/tags/$VERSION -H 'authorization: token $TOKEN' -H 'cache-control: no-cache' | python -c \"import sys, json; print json.load(sys.stdin)['id']\""
echo $GIT_HUB_RELEASE_DETAILS_URL
RELEASE_ID=$(eval "$GIT_HUB_RELEASE_DETAILS_URL")
echo $RELEASE_ID

# Upload artifact

#sh upload-asset.sh $VERSION $BRANCH

echo "[INFO] Release complete"