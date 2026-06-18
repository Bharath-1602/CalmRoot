# CalmRoot EKS Migration & Deployment Guide

This guide provides step-by-step instructions to deploy the CalmRoot platform onto Amazon EKS with Envoy Gateway and CloudFront integration, starting from a fresh AWS account.

---

## 📋 Prerequisites

Ensure the following tools are installed locally:
* **AWS CLI** (configured with admin credentials for account `006805625766`)
* **Node.js** (v18 or v20)
* **Docker Desktop** (running locally)
* **Terraform CLI** (v1.5+)
* **kubectl** & **Helm** (Kubernetes client utilities)

---

## 🚀 Step 1: Initialize Database & S3 Storage

Since your AWS account is fresh and empty, we need to create the active database tables and Clinical Notes S3 bucket:

1. **Install root dependencies**:
   ```bash
   npm install
   ```

2. **Initialize AWS Resources**:
   Run the utility script to create the 6 DynamoDB tables and the `calmroot-clinical-notes-006805625766` bucket in `us-east-1`:
   ```bash
   npm run create-resources
   ```
   *Note: Verify that the 6 tables and the S3 bucket are visible in your AWS Console.*

---

## 🛠️ Step 2: Bootstrap Infrastructure & OIDC

Next, set up the remote Terraform state lock and GitHub deployment authentication:

1. **Setup Remote State**:
   Run the backend helper to create the state S3 bucket `calmroot-terraform-state` and locks table `calmroot-terraform-locks`:
   ```bash
   bash scripts/setup-terraform-backend.sh
   ```

2. **Setup GitHub Actions OIDC role**:
   Run the OIDC helper to register GitHub and create the deployment role `calmroot-github-actions-role`:
   ```bash
   bash scripts/setup-github-oidc.sh
   ```

3. **Configure GitHub Secrets**:
   Copy the generated Role ARN and add it to your GitHub repository (**Settings ➔ Secrets and variables ➔ Actions ➔ Repository Secrets**):
   * `AWS_ROLE_ARN` = `arn:aws:iam::006805625766:role/calmroot-github-actions-role`
   * `AWS_REGION` = `us-east-1`

---

## 🏗️ Step 3: Terraform Pass 1 (Core Infrastructure)

Commit and push your files to trigger the pipeline and spin up EKS:

1. **Commit and Push**:
   ```bash
   git add .
   git commit -m "deploy: EKS migration files"
   git push origin main
   ```

2. **Approve Infrastructure Workflow**:
   * Navigate to the **Actions** tab on your GitHub repository.
   * Open the **Infrastructure — Terraform** run.
   * Approve the plan when prompted to start **Terraform Apply**.

3. **Update Nameservers (DNS Delegation)**:
   Once the pipeline finishes, copy the Route 53 Nameservers output from the GHA logs:
   * Log in to your domain registrar (Namecheap/GoDaddy/etc.).
   * Replace your registrar's nameservers for **`wellnest-project.online`** with the 4 Route 53 nameservers.
   * Wait a few minutes for propagation (propagation check: `https://dnschecker.org`).

---

## 🔐 Step 4: Configure Secrets & Bedrock Access

1. **Update Secrets Manager**:
   Open [scripts/update-secrets.sh](file:///c:/Users/bhara/OneDrive/Desktop/CalmRoot/scripts/update-secrets.sh), specify your production `JWT_SECRET` and `SES_SENDER_EMAIL`, and run:
   ```bash
   bash scripts/update-secrets.sh
   ```

2. **Verify SES Identity**:
   Go to the AWS SES console and verify your sender email.

3. **Enable AWS Bedrock Model Access**:
   Go to the AWS Bedrock console in `us-east-1`, navigate to **Model Access**, and click **Manage model access**. Enable:
   * **Amazon Nova Lite**
   * **Amazon Titan Text Express**

---

## ⛵ Step 5: Build Images & Deploy Application (Pass 1)

1. Navigate to the **Actions** tab in GitHub.
2. Select the **Deploy — Build & Ship to EKS** pipeline and click **Run workflow**.
3. This workflow will:
   * Concurrently compile Dockerfiles and push tagged images to ECR.
   * Install **Gateway API CRDs**, **Metrics Server**, and **External Secrets Operator**.
   * Deploy **Envoy Gateway** (which provisions the AWS NLB).
   * Deploy the **CalmRoot application** pods.

---

## 🌐 Step 6: Bind CloudFront CDN (Pass 2)

Now that the Envoy Gateway Load Balancer (NLB) exists, we need to bind CloudFront to it:

1. **Get the NLB DNS address**:
   Retrieve the allocated NLB hostname:
   ```bash
   aws eks update-kubeconfig --name calmroot-prod --region us-east-1
   kubectl get gateway calmroot-gateway -n calmroot-prod -o jsonpath='{.status.addresses[0].value}'
   ```
   *Expected output: `calmroot-nlb-*.elb.us-east-1.amazonaws.com`*

2. **Update NLB Variable**:
   Open [terraform/terraform.tfvars](file:///c:/Users/bhara/OneDrive/Desktop/CalmRoot/terraform/terraform.tfvars) and replace the placeholder `nlb_dns_name` with your actual NLB DNS address:
   ```hcl
   nlb_dns_name = "calmroot-nlb-xxx.elb.us-east-1.amazonaws.com"
   ```

3. **Commit and Apply**:
   ```bash
   git add terraform/terraform.tfvars
   git commit -m "infra: update nlb target to trigger cdn binding"
   git push origin main
   ```
4. Approve the **Infrastructure — Terraform** apply run in GitHub Actions. This will deploy the CloudFront CDN, map SSL certificates, and set Route 53 A alias records.

---

## 🔍 Step 7: Verification

Verify your EKS resources and test endpoint routing:

1. **Verify Pod Statuses**:
   ```bash
   kubectl get pods -n calmroot-prod
   ```

2. **Verify External Secrets Sync**:
   ```bash
   kubectl get externalsecrets -n calmroot-prod
   # Status should read: SecretSynced
   ```

3. **Verify HTTP Endpoint access**:
   Open your browser or run curl against your custom domain name:
   ```bash
   # Test Frontend loads
   curl -fI https://wellnest-project.online/
   
   # Test Auth health
   curl -f https://wellnest-project.online/api/auth/health
   
   # Test Rate limits (spamming auth-routes Chat)
   for i in {1..25}; do curl -i https://wellnest-project.online/api/chat/health; done
   # Should throw 429 Too Many Requests after 20 queries inside a minute
   ```
