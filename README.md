# IAC-infra Infrastructure as Code (IaC) Pipeline

This repository contains the necessary configurations to set up a scalable and robust infrastructure on Google Cloud Platform (GCP) using Terraform and Terragrunt. The project provisions a Kubernetes (GKE) cluster, Virtual Private Cloud (VPC), and a Content Delivery Network (CDN), with environments for development, staging, and production. The repository also contains a GitHub Actions pipeline for continuous integration (CI) that automates infrastructure management.

- **CDN Link**: URL discarded.

### CI Workflow

```
+-------------------+      
|    Trigger Event   | 
|                    | 
| Push to main/tag   | 
| PR to main branch  | 
+-------------------+
      |
      |
      v
+-----------------------+     
|     Checkout Code     |     
|  (actions/checkout@v3)|     
+-----------------------+      
      |
      v
+----------------------------+     
| Google Cloud Authentication|     
| (GCP Service Account Key)  |     
+----------------------------+     
      |
      v
+----------------------------+     
| Google Cloud SDK Setup     |     
| (gcloud setup)             |     
+----------------------------+     
      |
      v
+-------------------------------+     
| Terraform & Terragrunt Install|     
| (v1.9.5 Terraform, v0.67.5 TG)|     
+-------------------------------+
      |
      v
+---------------------------------------------+
| Set Environment Variables (dev, staging,    |
| prod based on branch/tag detection)         |
+---------------------------------------------+


    PULL REQUEST PROCESS                         MAIN/TAG PUSH PROCESS
+----------------------------------+          +--------------------------------------+
|   Terragrunt Plan (for PR)       |          |   Import Existing Resources          |
|   (Review infra changes via plan)|          |   (Check CDN, VPC resources)         |
+----------------------------------+          +--------------------------------------+
        |                                                   |
        v                                                   v
+----------------------------------+          +--------------------------------------+
| Validation (terragrunt validate) |          | Validation (terragrunt validate)     |
+----------------------------------+          +--------------------------------------+
                                                        |
                                                        v
                                         +----------------------------------------+
                                         | Push to main -> Terragrunt Apply       |
                                         | (Apply changes automatically to infra) |
                                         +----------------------------------------+

```
## Project Structure

```plaintext
iac-infra/
├── README.md
├── terraform/
│   ├── devplan.tfplan
│   ├── envs/
│   │   ├── dev/
│   │   │   └── terragrunt.hcl
│   │   ├── prod/
│   │   │   └── terragrunt.hcl
│   │   └── staging/
│   │       └── terragrunt.hcl
│   ├── main.tf
│   ├── modules/
│   │   ├── cdn/
│   │   ├── cdn_bucket/
│   │   ├── gke/
│   │   └── vpc/
│   ├── variables.tf
├── .github/
│   └── workflows/
│       └── ci-pipeline.yml
```

### Folder Descriptions

- **envs/**: Contains environment-specific configurations for `dev`, `staging`, and `prod` using Terragrunt to facilitate scalability and reusability.
  
- **modules/**: Modularized Terraform files for various infrastructure components:
  - **vpc/**: Manages the Virtual Private Cloud.
  - **gke/**: Configures the Google Kubernetes Engine (GKE) cluster.
  - **cdn_bucket/**: Provisions the storage bucket for CDN.
  - **cdn/**: Configures the Content Delivery Network.

- **main.tf**: Defines the core infrastructure resources for GCP (e.g., GKE, VPC, CDN).

- **variables.tf**: Contains variables used across all environments (e.g., project ID, region, machine type, etc.).

- **.github/workflows/**: Contains the GitHub Actions pipeline (`ci-pipeline.yml`) that automates infrastructure provisioning and management.

## CI/CD Pipeline

The CI pipeline is defined in the `.github/workflows/ci-pipeline.yml` file. This GitHub Actions workflow automates infrastructure management using Terragrunt and Terraform. The pipeline is triggered on:

- **Pushes** to the `main` branch and to any tags matching `*-dev`, `*-staging`, or `*-prod`.
- **Pull requests** targeting the `main` branch.

### Pipeline Workflow

1. **Checkout Repository**: Pulls the latest code from the repository.

2. **Authenticate to Google Cloud**: Uses the `google-github-actions/auth` action to authenticate using a service account key stored in GitHub Secrets.

3. **Set Up Google Cloud SDK**: Configures the Google Cloud SDK with the project ID for interaction with GCP resources.

4. **Install Terraform and Terragrunt**: Installs specific versions of Terraform (`v1.9.5`) and Terragrunt (`v0.67.5`) if they are not already installed.

5. **Set Environment Variables**: Determines the environment (dev, staging, prod) based on the tag or branch being deployed. Sets the appropriate path for the `terragrunt.hcl` file to ensure configuration consistency.

6. **Import Resources**: Checks if certain resources like the CDN bucket and VPC exist, and if not, imports them into the Terraform state.

7. **Terragrunt Initialize**: Initializes the Terraform backend and ensures proper state management using GCS for remote state.

8. **Validate Configuration**: Runs `terragrunt validate` to ensure the configuration is valid before proceeding with changes.

9. **Terragrunt Plan (Pull Requests)**: Runs a `terragrunt plan` on pull requests to generate and review infrastructure changes before merging.

10. **Terragrunt Apply (Main Branch)**: Applies infrastructure changes automatically when code is pushed to the `main` branch.

### Secret Management

The GitHub Actions pipeline leverages the following secrets to securely manage infrastructure:

- **`GCP_SA_KEY`**: Stores the Google Cloud Service Account credentials for authentication.
- **`TERRAFORM_BUCKET_NAME`**: Name of the GCS bucket where Terraform state is stored.

## Infrastructure Overview

### Google Kubernetes Engine (GKE)

The GKE cluster is provisioned with a configurable number of nodes and machine types. It is deployed into a well-configured VPC with proper subnetting and access control.

### Virtual Private Cloud (VPC)

A dedicated VPC is created for network isolation, and it provides proper subnetting for different environments. The `subnet_cidr` can be adjusted as needed.

### Content Delivery Network (CDN)

A GCS bucket is provisioned as a CDN-backed storage, optimized for serving static content. The CDN is linked to serve files like images via HTTP.

- **CDN Link**: [Flying Cat Image](http://34.160.38.196/flying-cat.png)

## How to Use

### Prerequisites

- Install [Terraform](https://www.terraform.io/downloads.html) and [Terragrunt](https://terragrunt.gruntwork.io/).
- Ensure you have the correct permissions to manage resources in GCP.
- Set up Google Cloud SDK and authenticate with your service account.

### Steps

1. **Clone the Repository**

   ```bash
   git clone https://github.com/your-repo/iac-infra.git
   cd iac-infra/terraform
   ```

2. **Set Up Environment Variables**

   Set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to the path of your Google Cloud service account JSON file:

   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="./path-to-your-service-account.json"
   ```

3. **Run Terragrunt Commands**

   For a specific environment (e.g., `dev`):

   ```bash
   cd envs/dev
   terragrunt plan
   terragrunt apply
   ```

4. **Destroy Infrastructure**

   To destroy the infrastructure:

   ```bash
   terragrunt destroy
   ```

## Continuous Integration & Deployment (CI/CD)

- **GitHub Actions**: The CI/CD pipeline automatically runs for `push` and `pull request` events on `main` and tagged environments (dev, staging, prod).
- **Validation**: The pipeline validates infrastructure changes on pull requests before applying them.
- **Automated Provisioning**: Changes pushed to `main` are automatically applied to the relevant environment using Terragrunt.

## Future Improvements

- **Crossplane Integration**: Add Crossplane to manage infrastructure directly from Kubernetes, allowing for enhanced resource management.
- **Atlantis Integration**: Use Atlantis for automated Terraform operations triggered by pull requests.
# icc-infra
# iac-infra
