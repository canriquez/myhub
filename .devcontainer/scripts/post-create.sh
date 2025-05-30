#!/bin/sh -e

echo "[post-create.sh] Starting script..."

# Check if k3d cluster 'experientiadev' exists
if ! k3d cluster get experientiadev > /dev/null 2>&1; then
  echo "[post-create.sh] Creating k3d cluster 'experientiadev'..."
  # Create k3d cluster:
  # --kubeconfig-update-default: k3d writes config to ~/.kube/config inside the container.
  # --kubeconfig-switch-context: k3d sets this cluster as the current kubectl context.
  k3d cluster create experientiadev \
    --agents 1 \
    --port '8080:80@loadbalancer' \
    --port '8443:443@loadbalancer' \
    --kubeconfig-update-default \
    --kubeconfig-switch-context
  echo "[post-create.sh] k3d cluster 'experientiadev' created and context switched."
else
  echo "[post-create.sh] k3d cluster 'experientiadev' already exists."
  # If cluster exists, ensure its context is the current one.
  kubectl config use-context k3d-experientiadev
  echo "[post-create.sh] Ensured kubectl context is set to existing k3d-experientiadev."
fi

# Wait for all nodes in the k3d cluster to be ready before proceeding
echo "[post-create.sh] Waiting for k3d nodes to be ready..."
kubectl wait --for=condition=Ready node --all --timeout=360s

# Final checks and version information
echo "[post-create.sh] Environment Ready!"
echo "[post-create.sh] --- Versions ---"
k3d --version
skaffold version
kubectl version --client
echo "[post-create.sh] --- k3d Cluster Nodes ---"
kubectl get nodes -o wide

echo "[post-create.sh] Script finished."