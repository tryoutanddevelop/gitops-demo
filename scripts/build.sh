#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Repository name is required."
    exit 1
fi

function log() {
    echo "$(date +"%Y-%m-%dT%H:%M:%S%z") - $1"
}
  

export IMAGE_REPO_NAME="$1"

aws ecr get-login-password --region $AWS_DEFAULT_REGION \
  | docker login \
  --username AWS \
  --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com

export GIT_BRANCH_NAME=`git symbolic-ref --short HEAD`
export GIT_COMMIT_ID=`git rev-parse HEAD`
export BUILD_EPOCH=`date +%s`
export IMAGE_TAG=$GIT_BRANCH_NAME-${GIT_COMMIT_ID:0:7}-$BUILD_EPOCH

log "Launching build script..."
log "-----------------------------------------------------------"
log "AWS_ACCOUNT_ID     : $AWS_ACCOUNT_ID"
log "AWS_DEFAULT_REGION : $AWS_DEFAULT_REGION"
log "IMAGE_REPO_NAME    : $IMAGE_REPO_NAME"
log "IMAGE_TAG          : $IMAGE_TAG"
log "-----------------------------------------------------------"

log "docker build starts..."
cd ..
docker build -t $IMAGE_REPO_NAME:$IMAGE_TAG .

log "tag the build..."
docker tag \
  $IMAGE_REPO_NAME:$IMAGE_TAG \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG

log "push to ECR..."
docker push \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG

log "Done"
log "-----------------------------------------------------------"