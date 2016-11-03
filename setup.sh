#!/bin/bash

# based on: https://lustforge.com/2016/02/27/hosting-hugo-on-aws/

# preconfiguration:
# aws configure set preview.cloudfront true

# Set your domain here
YOUR_DOMAIN="milanaleksic.net"
REGION="eu-central-1"
# Don't change these
BUCKET_NAME="${YOUR_DOMAIN}-cdn"
LOG_BUCKET_NAME="${BUCKET_NAME}-logs"

# One fresh bucket please!
#aws s3 mb s3://$BUCKET_NAME --region $REGION
# And another for the logs
#aws s3 mb s3://$LOG_BUCKET_NAME --region $REGION

# Let AWS write the logs to this location
#aws s3api put-bucket-acl --region $REGION --bucket $LOG_BUCKET_NAME \
#    --grant-write 'URI="http://acs.amazonaws.com/groups/s3/LogDelivery"' \
#    --grant-read-acp 'URI="http://acs.amazonaws.com/groups/s3/LogDelivery"'

# Setup logging
#LOG_POLICY="{\"LoggingEnabled\":{\"TargetBucket\":\"$LOG_BUCKET_NAME\",\"TargetPrefix\":\"$BUCKET_NAME\"}}"
#aws s3api put-bucket-logging --region $REGION --bucket $BUCKET_NAME --bucket-logging-status $LOG_POLICY

# Create website config
# echo "{
#     \"IndexDocument\": {
#         \"Suffix\": \"index.html\"
#     },
#     \"ErrorDocument\": {
#         \"Key\": \"404.html\"
#     },
#     \"RoutingRules\": [
#         {
#             \"Redirect\": {
#                 \"ReplaceKeyWith\": \"index.html\"
#             },
#             \"Condition\": {
#                 \"KeyPrefixEquals\": \"/\"
#             }
#         }
#     ]
# }" > website.json

# aws s3api put-bucket-website --region $REGION \
# 	--bucket $BUCKET_NAME --website-configuration file://website.json

# NOTE: IT MUST BE IN US-EAST-1 TO WORK WITH CLOUDFRONT
# aws acm request-certificate --domain-name $YOUR_DOMAIN \
# 	--region us-east-1 \
# 	--subject-alternative-names "www.$YOUR_DOMAIN" \
# 	--idempotency-token "`date +%s`"

#TODO 
# aws acm list-certificates --region us-east-1 --certificate-statuses ISSUED

# From above
# SSL_ARN="arn:aws:acm:us-east-1:354361942757:certificate/d25e586c-f67b-4b32-bc23-23c7bba57ff4"

# CALLER_REF="`date +%s`" # current second
# echo "{
#     \"Comment\": \"$BUCKET_NAME Static Hosting\", 
#     \"Logging\": {
#         \"Bucket\": \"$LOG_BUCKET_NAME.s3.amazonaws.com\", 
#         \"Prefix\": \"${BUCKET_NAME}-cf/\", 
#         \"Enabled\": true,
#         \"IncludeCookies\": false
#     }, 
#     \"Origins\": {
#         \"Quantity\": 1,
#         \"Items\": [
#             {
#                 \"Id\":\"$BUCKET_NAME-origin\",
#                 \"OriginPath\": \"\", 
#                 \"CustomOriginConfig\": {
#                     \"OriginProtocolPolicy\": \"http-only\", 
#                     \"HTTPPort\": 80, 
#                     \"OriginSslProtocols\": {
#                         \"Quantity\": 3,
#                         \"Items\": [
#                             \"TLSv1\", 
#                             \"TLSv1.1\", 
#                             \"TLSv1.2\"
#                         ]
#                     }, 
#                     \"HTTPSPort\": 443
#                 }, 
#                 \"DomainName\": \"$BUCKET_NAME.s3-website-$REGION.amazonaws.com\"
#             }
#         ]
#     }, 
#     \"DefaultRootObject\": \"index.html\", 
#     \"PriceClass\": \"PriceClass_All\", 
#     \"Enabled\": true, 
#     \"CallerReference\": \"$CALLER_REF\",
#     \"DefaultCacheBehavior\": {
#         \"TargetOriginId\": \"$BUCKET_NAME-origin\",
#         \"ViewerProtocolPolicy\": \"redirect-to-https\", 
#         \"DefaultTTL\": 1800,
#         \"AllowedMethods\": {
#             \"Quantity\": 2,
#             \"Items\": [
#                 \"HEAD\", 
#                 \"GET\"
#             ], 
#             \"CachedMethods\": {
#                 \"Quantity\": 2,
#                 \"Items\": [
#                     \"HEAD\", 
#                     \"GET\"
#                 ]
#             }
#         }, 
#         \"MinTTL\": 0, 
#         \"Compress\": true,
#         \"ForwardedValues\": {
#             \"Headers\": {
#                 \"Quantity\": 0
#             }, 
#             \"Cookies\": {
#                 \"Forward\": \"none\"
#             }, 
#             \"QueryString\": false
#         },
#         \"TrustedSigners\": {
#             \"Enabled\": false, 
#             \"Quantity\": 0
#         }
#     }, 
#     \"ViewerCertificate\": {
#         \"SSLSupportMethod\": \"sni-only\", 
#         \"ACMCertificateArn\": \"$SSL_ARN\", 
#         \"MinimumProtocolVersion\": \"TLSv1\", 
#         \"Certificate\": \"$SSL_ARN\", 
#         \"CertificateSource\": \"acm\"
#     }, 
#     \"CustomErrorResponses\": {
#         \"Quantity\": 2,
#         \"Items\": [
#             {
#                 \"ErrorCode\": 403, 
#                 \"ResponsePagePath\": \"/404.html\", 
#                 \"ResponseCode\": \"404\",
#                 \"ErrorCachingMinTTL\": 300
#             }, 
#             {
#                 \"ErrorCode\": 404, 
#                 \"ResponsePagePath\": \"/404.html\", 
#                 \"ResponseCode\": \"404\",
#                 \"ErrorCachingMinTTL\": 300
#             }
#         ]
#     }, 
#     \"Aliases\": {
#         \"Quantity\": 2,
#         \"Items\": [
#             \"$YOUR_DOMAIN\", 
#             \"www.$YOUR_DOMAIN\"
#         ]
#     }
# }" > distroConfig.json

# # Now apply it
# aws cloudfront create-distribution --region $REGION --distribution-config file://distroConfig.json

# TODO
# aws cloudfront list-distributions --query 'DistributionList.Items[].{id:Id,comment:Comment,domain:DomainName}'
