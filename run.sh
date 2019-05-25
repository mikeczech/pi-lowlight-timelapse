#!/usr/bin/env bash

set -e

readonly TERRAFORM_URL="https://releases.hashicorp.com/terraform/0.12.0/terraform_0.12.0_linux_arm.zip"
readonly TERRAFROM_SHA256="ea7bc7ed4452f3e2fc74cde8cdc9b42daea0c38b6255326e2911d7ae16bfb166"

function ensure_gcloud {
  if [[ -z "${GCP_PROJECT_ID}" ]]; then
    echo "Please set GCP_PROJECT_ID"
    exit 1
  fi

  gcloud config set project "$GCP_PROJECT_ID"
  if [ -z "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
    local default_credentials_path=~/.config/gcloud/application_default_credentials.json
    if [ ! -f "$default_credentials_path" ]; then
        gcloud auth application-default login
    else
      echo "Using default credentials $default_credentials_path"
    fi
  else
    gcloud auth activate-service-account --key-file "$GOOGLE_APPLICATION_CREDENTIALS"
  fi
}

function ensure_terraform {
  if ! [ -f "$(pwd)/bin/terraform" ]; then
    mkdir -p "$(pwd)/bin"
    curl -L "$TERRAFORM_URL" > terraform.zip
    unzip -p terraform.zip > "$(pwd)/bin/terraform"
    chmod +x "$(pwd)/bin/terraform"
    rm terraform.zip
  fi
  export PATH="$(pwd)/bin:$PATH"
}

function task_capture {
  ensure_gcloud

  pipenv run python python/main.py
}

function task_usage {
  echo 'Usage: ./run.sh tf | capture'
  exit 1
}

function task_tf {
  ensure_gcloud
  ensure_terraform

  cd terraform
  terraform init
  terraform "$@" -var project="$GCP_PROJECT_ID"
}

cmd=$1
shift || true
case "$cmd" in
  tf) task_tf "$@" ;;
  capture) task_capture ;;
  *)     task_usage ;;
esac
