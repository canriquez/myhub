# MyHub Application - Local Development Environment Setup

This guide provides step-by-step instructions to set up and run the MyHub application locally for development using Skaffold, Kustomize, and Rancher Desktop for Kubernetes.

## Overview

The local development environment utilizes:
- **Rancher Desktop:** Provides the Docker daemon and a local Kubernetes (k3s) cluster.
- **Skaffold:** Orchestrates the build, image loading, and deployment lifecycle for rapid iteration.
- **Kustomize:** Manages Kubernetes manifest customization, including dynamic generation of a `Secret` object from a local `.env` file.
- **Local `.env` file:** For managing environment-specific configurations and secrets locally without committing them to Git.

## Prerequisites

Before you begin, ensure you have the following installed on your host machine:

1.  **Operating System:** This guide is optimized for macOS with Apple Silicon (M-series chips). Users on other operating systems (Intel Macs, Windows, Linux) may need to make minor adjustments (see "Important Notes" section).
2.  **Homebrew:** (Recommended for macOS installations) If not already installed, get it from [brew.sh](https://brew.sh/).
3.  **Rancher Desktop:**
    * Download and install from [rancherdesktop.io](https://rancherdesktop.io/).
    * During setup, or in Preferences:
        * Ensure **Kubernetes is enabled**.
        * Select a recent stable version of Kubernetes.
4.  **kubectl (Kubernetes CLI):**
    * macOS: `brew install kubectl`
    * Other OS: Follow official Kubernetes documentation.
5.  **Skaffold CLI:**
    * macOS: `brew install skaffold`
    * Other OS: Follow official Skaffold documentation.
6.  **Kustomize CLI:**
    * macOS: `brew install kustomize`
    * Other OS: Follow official Kustomize documentation.
7.  **Git:** For cloning the repository.

## Setup Instructions

### 1. Clone the Repository
```bash
git clone <your-repository-url> # Replace with your project's repository URL
cd myhub # Or your repository's root directory
```

### 2. Configure Rancher Desktop and `kubectl`

1.  **Start Rancher Desktop:** Ensure it's running and its Kubernetes cluster has initialized.
2.  **Set `kubectl` Context:** Your `kubectl` command-line tool needs to target the Kubernetes cluster provided by Rancher Desktop.
    * List available contexts:
        ```bash
        kubectl config get-contexts
        ```
    * Switch to the Rancher Desktop context (usually named `rancher-desktop`):
        ```bash
        kubectl config use-context rancher-desktop
        ```
    * Verify the current context:
        ```bash
        kubectl config current-context
        ```
        *(Should output `rancher-desktop`)*
    * Verify connection to the cluster:
        ```bash
        kubectl get nodes
        ```
        *(Should show node(s) managed by Rancher Desktop. On Apple Silicon Macs, the architecture will be `arm64`.)*

### 3. Set Up Local Environment Variables

The application requires environment variables for configuration and secrets. This project includes an `.env-example` file to guide you.

1.  **Locate `.env-example`:** This file is provided in the repository (e.g., at the project root or within the `k8s/` directory – please check its location in this repo). Let's assume it's in the `k8s/` directory for this guide.

2.  **Create Your Local `.env` File:**
    Copy the example file to `k8s/.env`. This new `k8s/.env` file will be used by Kustomize.
    ```bash
    cp k8s/.env-example k8s/.env
    ```

3.  **Populate `k8s/.env`:**
    Open `k8s/.env` with your text editor and replace all placeholder values (like `<YOUR_POSTGRES_DEV_PASSWORD>` or `<GENERATE_A_STRONG_SECRET_KEY_BASE_FOR_DEV>`) with your actual local development credentials and configurations.
    *(See the `.env-example` content below for structure.)*

4.  **IMPORTANT: Add `k8s/.env` to `.gitignore`:**
    Ensure your local `k8s/.env` file (which contains your actual secrets) is **never committed to Git**. Add the following line to your project's root `.gitignore` file:
    ```gitignore
    # Local environment variables for Kustomize
    k8s/.env
    ```
    Commit your `.gitignore` file if you've updated it.

### `.env-example` Content Structure

This file should be present in the repository (e.g., `k8s/.env-example`) for developers to copy from.
```ini
# PostgreSQL Configuration
POSTGRES_USER=postgres
POSTGRES_PASSWORD=<YOUR_POSTGRES_DEV_PASSWORD>
POSTGRES_DB_DEVELOPMENT=myhub_development
POSTGRES_DB_TEST=myhub_test
POSTGRES_DB_PRODUCTION=myhub_production
POSTGRES_HOST=postgres-rayces # Kubernetes Service name for PostgreSQL
POSTGRES_PORT="5432"

# Rails Configuration
RAILS_PORT="4000"
RACK_ENV=development
RAILS_ENV=development
RAILS_LOG_TO_STDOUT="true"
RAILS_SERVE_STATIC_FILES="true"
SECRET_KEY_BASE=<GENERATE_A_STRONG_SECRET_KEY_BASE_FOR_DEV_EG_VIA_RAILS_SECRET>

# Shared OAuth / API Keys (use non-production dev keys if possible)
GOOGLE_CLIENT_ID=<YOUR_DEV_GOOGLE_CLIENT_ID_FROM_CLOUD_PROJECT>
GOOGLE_CLIENT_SECRET=<YOUR_DEV_GOOGLE_CLIENT_SECRET_FROM_CLOUD_PROJECT>

# Next.js Environment Variables
NEXTAUTH_SECRET=<GENERATE_A_RANDOM_STRONG_NEXTAUTH_SECRET_FOR_DEV_EG_VIA_OPENSSL>
NEXTAUTH_URL=http://localhost:8080 # Adjust if your service is exposed on a different port

# Client-side Environment Variables for Next.js (prefixed with NEXT_PUBLIC_)
NEXT_PUBLIC_DOMAIN=localhost # Or your local dev domain
NEXT_PUBLIC_API_LLM_TOKEN=<YOUR_DEV_MYHUB_APP_API_TOKEN_TO_RUN_LLM>
NEXT_PUBLIC_RAILS_BACKEND=http://localhost:4000 # URL frontend uses to reach backend
NEXT_PUBLIC_RAILS_BACKEND_PROBE=http://localhost:4000/up # Backend health check
```

## Running the Application

With all prerequisites and setup steps completed:

1.  **Navigate to the project root directory** in your terminal.
2.  **Start the development environment using Skaffold:**
    ```bash
    skaffold dev
    ```

**What `skaffold dev` does:**
* Builds your application images (`rayces-backend`, `rayces-frontend`) locally using Rancher Desktop's Docker daemon.
* Loads these images into your local Rancher Desktop Kubernetes cluster.
* Uses Kustomize to process manifests in the `k8s/` directory. This includes:
    * Running the `secretGenerator` defined in `k8s/kustomization.yaml` to read `k8s/.env` and create a Kubernetes `Secret` object named `raycesv3-environment`.
    * Applying all other Kubernetes manifests (Deployments, Services, PVCs).
* Streams logs from your running application pods to your terminal.
* Watches your local source files for changes, enabling hot-reloading or quick rebuilds.

### Accessing Your Applications

* Your applications (Next.js frontend, Rails backend) will be exposed via Kubernetes Services.
* If using `LoadBalancer` type services in `k3d` (which Rancher Desktop uses), k3d's service load balancer maps service ports to ports on your host machine (e.g., `localhost:8080` for frontend, `localhost:4000` for backend, depending on your service definitions and k3d port mappings).
* Check the output of `kubectl get services -n raycesv3` to see how services are exposed and their `EXTERNAL-IP` (often `localhost` for Rancher Desktop) and `PORT(S)`.

## Database Seeding (Optional On-Demand Step)

If your database needs to be seeded with initial data (and you have the `seed-db` profile configured in `skaffold.yaml` and the `k8s/rails-seeding-job-run-only-once.yaml` manifest):

1.  Ensure PostgreSQL is running (can be done after an initial `skaffold dev` run that stabilizes PostgreSQL).
2.  In a new terminal window, navigate to your project root and run:
    ```bash
    skaffold run -p seed-db
    ```
    This will build the backend image (if needed), delete any previous seed job, and run the new seed job.

## Stopping the Development Environment

* Press `Ctrl+C` in the terminal where `skaffold dev` is running. Skaffold will attempt to clean up the resources it deployed.

## Cleaning Up Kubernetes Resources (Optional)

To remove all deployed Kubernetes resources by Skaffold:
```bash
skaffold delete
```
To completely reset the Kubernetes cluster provided by Rancher Desktop:
* Go to Rancher Desktop Preferences > Kubernetes.
* Click "Reset Kubernetes..."

## Important Notes

* **Apple Silicon (M-series Macs):** This setup is primarily tested for macOS on Apple Silicon. Rancher Desktop will automatically build `linux/arm64` images, which is suitable for its ARM64-based Kubernetes cluster. The `skaffold.yaml` provided omits explicit `platform: "linux/arm64"` flags for artifacts, relying on this default behavior. If you are on an Intel Mac or another OS/architecture and encounter issues, you might need to adjust the Skaffold build configuration to specify the correct target platform (e.g., `platform: "linux/amd64"`).
* **Dockerfile Customization:** The Dockerfiles provided in this repository are tailored for a Rails/Next.js application. You may need to customize them if your project uses a different stack or has specific build requirements.

## Troubleshooting

* **`kubectl` context:** Always ensure `kubectl config current-context` is `rancher-desktop`.
* **Rancher Desktop:** Make sure it's running and Kubernetes is enabled. Check its logs for any issues.
* **`.env` file:** Double-check that `k8s/.env` exists, is populated with **all required variables**, and that the keys exactly match what your application deployments expect from the `raycesv3-environment` Secret.
```