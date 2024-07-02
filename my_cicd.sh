#!/bin/bash

echo "Fetching temporary credentials..."
echo "Setting environment variables..."
export TF_VAR_secret_id=IKID9i38xZw61g8MN9zhheNr66rQmCXguERd
export TF_VAR_secret_key=7ze9RULg6i7Zt3DEzby5xZv3FG6iAPTN

if [ "$1" == "init" ]; then
    terraform init -input=false -upgrade
elif [ "$1" == "plan" ]; then
    terraform plan -var "secret_id=${TF_VAR_secret_id}" -var "secret_key=${TF_VAR_secret_key}"
elif [ "$1" == "apply" ]; then
    terraform apply -auto-approve -var "secret_id=${TF_VAR_secret_id}" -var "secret_key=${TF_VAR_secret_key}"
else
    echo "Unknown command: $1"
    exit 1
fi

