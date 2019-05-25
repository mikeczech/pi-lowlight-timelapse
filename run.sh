#!/usr/bin/env bash

set -e

TERRAFORM_URL="https://releases.hashicorp.com/terraform/0.12.0/terraform_0.12.0_linux_arm.zip"
TERRAFROM_SHA256="ea7bc7ed4452f3e2fc74cde8cdc9b42daea0c38b6255326e2911d7ae16bfb166"

function ensure_terraform {
  if ! [ -x "$(command -v git)" ]; then
    mkdir -p "$(pwd)/bin"
    curl -L "$TERRAFROM_URL" > terraform.zip
    unzip -p terraform.zip > "$(pwd)/bin/terraform"
    rm terraform
    export PATH="$(pwd)/bin:$PATH"
  fi
}

function task_usage {
  echo 'Usage: ./run.sh tf'
  exit 1
}

function task_tf {
  ensure_terraform

  cd terraform
  terrafrom "$@"
}

cmd=$1
shift || true
case "$cmd" in
  tf) task_tf "$@" ;;
  *)     task_usage ;;
esac
