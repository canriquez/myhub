#!/bin/sh -e

CLUSTER_NAME="experientiadev"
K3D_CONTEXT_NAME="k3d-${CLUSTER_NAME}"

echo "[post-start.sh] Starting script for cluster: ${CLUSTER_NAME}..."

if k3d cluster get "${CLUSTER_NAME}" > /dev/null 2>&1; then
  # This is the robust way to ensure the kubectl context is correctly configured.
  # It tells k3d to merge the cluster's config into the default kubeconfig file
  # and switch the current context to it.
  echo "[post-start.sh] Ensuring kubeconfig is updated and context is set to '${K3D_CONTEXT_NAME}'..."
  k3d kubeconfig merge "${CLUSTER_NAME}" --kubeconfig-merge-default --kubeconfig-switch-context
  
  echo -n "[post-start.sh] Current kubectl context is now: "
  kubectl config current-context
else
  echo "[post-start.sh] WARNING: k3d cluster '${CLUSTER_NAME}' not found. It might need to be created (rebuild container if so)."
fi

echo "[post-start.sh] Script finished."