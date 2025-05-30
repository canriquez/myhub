#!/bin/sh -e

echo "[post-start.sh] Starting script..."

# Ensure the k3d context is active on every start, in case it was changed.
if k3d cluster get experientiadev > /dev/null 2>&1; then
  echo "[post-start.sh] Ensuring kubectl context is set to k3d-experientiadev..."
  kubectl config use-context k3d-experientiadev
  echo -n "[post-start.sh] Current kubectl context: "
  kubectl config current-context
else
  echo "[post-start.sh] WARNING: k3d cluster experientiadev not found. It might need to be created (rebuild container if so)."
fi

echo "[post-start.sh] Script finished."