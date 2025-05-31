#!/bin/sh -e

# --- Tool Installation ---
echo "[post-create.sh] Installing SOPS and Age with sudo..."
SOPS_VERSION="v3.8.1"
AGE_VERSION="v1.1.1"
# Set ARCH to "amd64" if your host machine is Intel/AMD
ARCH="arm64" 

# 1. Download to /tmp (a user-writable directory)
curl -Lo /tmp/sops https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.${ARCH}
curl -Lo /tmp/age.tar.gz https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-linux-${ARCH}.tar.gz

# 2. Unpack age in /tmp
tar -xzf /tmp/age.tar.gz -C /tmp

# 3. Use 'sudo' to move the binaries to the system path and set permissions
echo "[post-create.sh] Moving binaries to /usr/local/bin..."
sudo mv /tmp/sops /usr/local/bin/sops
sudo mv /tmp/age/age /usr/local/bin/age
sudo mv /tmp/age/age-keygen /usr/local/bin/age-keygen
sudo chmod +x /usr/local/bin/sops /usr/local/bin/age /usr/local/bin/age-keygen

# 4. Clean up temporary files
rm /tmp/age.tar.gz
rm -rf /tmp/age

echo "[post-create.sh] SOPS and Age installed successfully."

# Installs Kustomize

echo "[post-create.sh] Installing Kustomize..."
KUSTOMIZE_VERSION="v5.6.0" # Check for the latest version
curl -Lo /tmp/kustomize.tar.gz "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz"
tar -xzf /tmp/kustomize.tar.gz -C /tmp
sudo mv /tmp/kustomize /usr/local/bin/kustomize
sudo chmod +x /usr/local/bin/kustomize
rm /tmp/kustomize.tar.gz
echo "[post-create.sh] Kustomize installed: $(kustomize version --short)"

# --- Cluster Creation ---
CLUSTER_NAME="experientiadev" # Define a name for your local cluster

echo "[post-create.sh] Starting script for cluster: ${CLUSTER_NAME}..."
if ! k3d cluster get "${CLUSTER_NAME}" > /dev/null 2>&1; then
  echo "[post-create.sh] Creating k3d cluster '${CLUSTER_NAME}'..."
  # Using 8080 and 8443 to avoid conflicts with host ports 80/443
  k3d cluster create "${CLUSTER_NAME}" \
    --agents 1 \
    --port '8080:80@loadbalancer' \
    --port '8443:443@loadbalancer' \
    --kubeconfig-update-default \
    --kubeconfig-switch-context
  echo "[post-create.sh] k3d cluster '${CLUSTER_NAME}' created and context switched."
else
  echo "[post-create.sh] k3d cluster '${CLUSTER_NAME}' already exists."
  # If cluster exists, ensure k3d properly merges its config and switches context.
  # This command will update ~/.kube/config and set the current context to k3d-experientiadev.
  echo "[post-create.sh] Ensuring kubeconfig is updated and context is switched for 'k3d-${CLUSTER_NAME}'..."
  k3d kubeconfig merge "${CLUSTER_NAME}" --kubeconfig-merge-default --kubeconfig-switch-context
  echo "[post-create.sh] Kubectl context ensured for 'k3d-${CLUSTER_NAME}'."
fi

# --- Finalization ---
echo "[post-create.sh] Waiting for k3d nodes to be ready..."
# The following command relies on the kubectl context being correctly set above.
kubectl wait --for=condition=Ready node --all --timeout=360s

echo "[post-create.sh] Environment Ready!"
echo "[post-create.sh] --- Versions ---"
k3d --version
skaffold version
kubectl version --client
echo "[post-create.sh] --- k3d Cluster Nodes (${CLUSTER_NAME}) ---"
kubectl get nodes -o wide

echo "[post-create.sh] Script finished."