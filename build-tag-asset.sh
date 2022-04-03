#!/bin/bash
VERSION=""
BRANCH="$1"
RELEASE_NOTES="$2"
BUILD_PATH="$(pwd)"
MODULE="sas-client"
TOKEN="$(cat git-token.txt | openssl enc -aes-256-cbc -md sha512 -a -d -pbkdf2 -iter 100000 -salt -pass pass:Secret@123#)"
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
git push https://$TOKEN@github.com/$REPO.git refs/releases/$VERSION

set +e
git push https://$TOKEN@github.com/$REPO.git :refs/releases/$VERSION
git tag -d $VERSION
set -e
git tag -m "[skip-ci] Development tag" $VERSION
git push https://$TOKEN@github.com/$REPO.git refs/releases/$VERSION


echo "Package build as zip file..."
jar -cfM sas-client-$VERSION.zip dist

sleep 2

# Generate Release
GIT_HUB_RELEASE_URL="curl -i -g -X POST $GITHUB/$REPO/releases -H 'authorization: token $TOKEN' -H 'cache-control: no-cache' -H 'content-type: application/json' -d '{\"tag_name\": \"$VERSION\",\"target_commitish\": \"$BRANCH\",\"name\": \"$VERSION\",\"body\": \"$RELEASE_NOTES\",\"draft\": false,\"prerelease\": true}'"
echo $GIT_HUB_RELEASE_URL
eval "$GIT_HUB_RELEASE_URL"

# Upload artifact

#sh upload-asset.sh $VERSION $BRANCH

echo "[INFO] Release complete"