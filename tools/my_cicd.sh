#!/bin/bash


echo "Fetching temporary credentials..."
# 读取文件内容并设置为环境变量
if [ -f /tmp/sts_tmpSecretId ]; then
    export TMP_SECRET_ID=$(cat /tmp/sts_tmpSecretId)
else
    echo "File /tmp/sts_tmpSecretId not found"
    exit 1
fi

if [ -f /tmp/sts_tmpSecretKey ]; then
    export TMP_SECRET_KEY=$(cat /tmp/sts_tmpSecretKey)
else
    echo "File /tmp/sts_tmpSecretKey not found"
    exit 1
fi

if [ -f /tmp/sts_token ]; then
    export TOKEN=$(cat /tmp/sts_token)
else
    echo "File /tmp/sts_token not found"
    exit 1
fi

if [ -f /tmp/ak ]; then
    export AK=$(cat /tmp/ak)
else
    echo "File /tmp/ak not found"
    exit 1
fi

if [ -f /tmp/sk ]; then
    export SK=$(cat /tmp/sk)
else
    echo "File /tmp/sk not found"
    exit 1
fi

# 打印环境变量确认
echo "Setting environment variables..."

export TENCENTCLOUD_SECRET_ID=$TMP_SECRET_ID
export TENCENTCLOUD_SECRET_KEY=$TMP_SECRET_KEY
export TENCENTCLOUD_SECURITY_TOKEN=$TOKEN

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

