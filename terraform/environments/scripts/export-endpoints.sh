#!/usr/bin/env sh

BASEDIR=$(dirname "$0")

# exit when any command fails
set -e
WORKSPACE=$1

cd $BASEDIR/../ >/dev/null

export TF_LOG=TRACE
export TF_LOG_PATH=terraform-export.log

terraform init 1>/dev/null
terraform workspace select $WORKSPACE 1>/dev/null
terraform refresh -var="image_tag=dummy" 1>/dev/null

echo "export DONATIONS_API_URL=$(terraform output --raw donations_api_url)"
echo "export GEO_API_URL=$(terraform output --raw geo_api_url)"
echo "export GOODNEWS_API_URL=$(terraform output --raw goodnews_api_url)"
echo "export OKUNA_URL=$(terraform output --raw okuna_url)"
echo "export VOLUNTEERING_API_URL=$(terraform output --raw volunteering_api_url)"
echo "export NOTIFICATIONS_API_URL=$(terraform output --raw notifications_api_url)"
echo "export TRACKING_ENDPOINT_URL=$(terraform output --raw tracking_endpoint_url)"
