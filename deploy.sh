#!/bin/bash

DISTRIBUTION_ID=E2JJSCIKYBNNNS
BUCKET_NAME=milanaleksic.net-cdn
REGION="eu-central-1"

# Build a fresh copy
hugo -v 

# Copy over pages - not static js/img/css/downloads
aws s3 --region $REGION sync --acl "public-read" --sse "AES256" public/ s3://$BUCKET_NAME --exclude 'post'

# Invalidate root page and page listings
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths '/*'