#!/bin/bash

# establish branch and tag name variables
releaseBranch=$1
tagName=$2

echo "Started releasing $versionLabel for $projectName ....."

# pull the latest version of the code from master
git pull

# create empty commit from master branch
git commit --allow-empty -m "Creating Branch $releaseBranch"

# create tag for new version from -master
git tag $tagName

# push commit to remote origin
git push

# push tag to remote origin
git push --tags origin 
 
# create the release branch from the -master branch
git checkout -b $releaseBranch $masterBranch

# push local releaseBranch to remote
git push -u origin $releaseBranch