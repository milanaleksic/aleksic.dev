#!/bin/bash

DISTRIBUTION_ID=E2JJSCIKYBNNNS
BUCKET_NAME=milanaleksic.net-cdn
REGION="eu-central-1"

# Build a fresh copy
hugo -v 

function aws() {
	docker run -i --rm \
		-v `pwd`:/data \
		-v `pwd`/.aws:/root/.aws \
	    --env AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
	    --env AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
	    garland/aws-cli-docker \
	    aws --region $AWS_REGION $*
}

# Copy over pages - not static js/img/css/downloads
aws s3 --region $REGION sync --acl "public-read" --sse "AES256" /data/public/ s3://$BUCKET_NAME --exclude 'public/cv*'

# backwards-compatible links don't have .pdf extensions, so upload must happen manually
aws s3 cp /data/public/public/cv s3://milanaleksic.net-cdn/public/ --content-type 'application/pdf' --acl "public-read" --sse "AES256"
aws s3 cp /data/public/public/cv-app1 s3://milanaleksic.net-cdn/public/ --content-type 'application/pdf' --acl "public-read" --sse "AES256"
aws s3 cp /data/public/public/cv-app2 s3://milanaleksic.net-cdn/public/ --content-type 'application/pdf' --acl "public-read" --sse "AES256"
aws s3 cp /data/public/public/cv-app3 s3://milanaleksic.net-cdn/public/ --content-type 'application/pdf' --acl "public-read" --sse "AES256"
aws s3 cp /data/public/public/cv-app4 s3://milanaleksic.net-cdn/public/ --content-type 'application/pdf' --acl "public-read" --sse "AES256"
aws s3 cp /data/public/public/cv-nostrification s3://milanaleksic.net-cdn/public/ --content-type 'image/jpeg' --acl "public-read" --sse "AES256"

# Invalidate root page and page listings
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths '/'