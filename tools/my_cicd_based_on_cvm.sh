#!/bin/bash


echo "Fetching temporary credentials..."

# get tencent cloud STS from cvm metadata server
response=$(curl -s http://metadata.tencentyun.com/latest/meta-data/cam/security-credentials/role_for_terraform_based_on_cvm)

# parsing the json response, and export to system variable
while IFS=':' read -r key value; do
  key=$(echo "$key" | sed 's/^ *//;s/ *$//;s/^"//;s/"$//')
  value=$(echo "$value" | sed 's/^ *//;s/ *$//;s/^"//;s/"$//')

  export "$key"="$value"
done < <(echo "$response" | jq -r 'to_entries[] | "\(.key):\(.value)"')

# print related system variable
env | grep -E "TmpSecretId|TmpSecretKey|Token"

# 打印环境变量确认
echo "Setting environment variables..."

export TENCENTCLOUD_SECRET_ID=$TmpSecretId
export TENCENTCLOUD_SECRET_KEY=$TmpSecretKey
export TENCENTCLOUD_SECURITY_TOKEN=$Token

echo "TENCENTCLOUD_SECRET_ID=$TENCENTCLOUD_SECRET_ID"
echo "TENCENTCLOUD_SECRET_KEY=$TENCENTCLOUD_SECRET_KEY"
echo "TENCENTCLOUD_SECURITY_TOKEN=$TENCENTCLOUD_SECURITY_TOKEN"


if [ "$1" == "init" ]; then
    terraform init -input=false -upgrade
elif [ "$1" == "plan" ]; then
    terraform plan
elif [ "$1" == "apply" ]; then
    # terraform apply -auto-approve
    terraform apply -auto-approve
else
    echo "Unknown command: $1"
    exit 1
fi
