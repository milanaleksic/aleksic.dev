#!/bin/bash

DISTRIBUTION_ID=E2JJSCIKYBNNNS
BUCKET_NAME=milanaleksic.net-cdn
REGION="eu-central-1"

function hugod() {
	docker run --rm \
		-v $(pwd):/src \
		-v $(pwd)/public:/output \
		--user `id -u $USER`:`id -g $USER` \
		jojomi/hugo "$@"
}

function awsd() {
	docker run -i --rm \
		-v `pwd`:/data \
		-v `pwd`/.aws:/root/.aws \
	    --env AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
	    --env AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
	    garland/aws-cli-docker \
	    aws --region $REGION "$@"
}

# Build a fresh copy
hugod -v

# Copy over pages - not static js/img/css/downloads
awsd s3 --region $REGION sync --acl "public-read" --sse "AES256" /data/public/ s3://$BUCKET_NAME --exclude 'public/cv*'

# backwards-compatible links don't have .pdf extensions, so upload must happen manually
awsd s3 cp /data/public/public/cv s3://milanaleksic.net-cdn/public/ --content-type 'application/pdf' --acl "public-read" --sse "AES256"
awsd s3 cp /data/public/public/cv-app1 s3://milanaleksic.net-cdn/public/ --content-type 'application/pdf' --acl "public-read" --sse "AES256"
awsd s3 cp /data/public/public/cv-app2 s3://milanaleksic.net-cdn/public/ --content-type 'application/pdf' --acl "public-read" --sse "AES256"
awsd s3 cp /data/public/public/cv-app3 s3://milanaleksic.net-cdn/public/ --content-type 'application/pdf' --acl "public-read" --sse "AES256"
awsd s3 cp /data/public/public/cv-app4 s3://milanaleksic.net-cdn/public/ --content-type 'application/pdf' --acl "public-read" --sse "AES256"
awsd s3 cp /data/public/public/cv-nostrification s3://milanaleksic.net-cdn/public/ --content-type 'image/jpeg' --acl "public-read" --sse "AES256"

# # Invalidate root page and page listings
awsd cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths '/'