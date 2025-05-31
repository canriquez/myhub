#!/bin/sh -e

# This script decrypts the k8s/secret.yaml file (path relative to kustomization.yaml)
# and outputs its content to stdout. Kustomize will then parse this output.

# This path should be relative to the location of your kustomization.yaml file.
# If kustomization.yaml is in ./k8s/, and secret.yaml is also in ./k8s/,
# then the path here should just be "secret.yaml".
ENCRYPTED_SECRET_FILE="secret.yaml" 

# You can add a check to see if the script is being run from the expected directory
# echo "Current directory for sops-decrypt-secret.sh: $(pwd)" >&2

if [ ! -f "$ENCRYPTED_SECRET_FILE" ]; then
  echo "Error: Encrypted secret file not found at $(pwd)/$ENCRYPTED_SECRET_FILE" >&2
  exit 1
fi

sops --decrypt "$ENCRYPTED_SECRET_FILE"