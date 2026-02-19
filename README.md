# Production-Grade Kubernetes Platform on AWS (EKS)
<sub>Note: Still in testing phase...</sub>

## Overview
This project demonstrates the design, deployment, and operation of a
production-grade Kubernetes platform on AWS using EKS. The focus is on
reliability, security, observability, and automation.

## Architecture
- AWS VPC (2 AZ)
- EKS cluster (managed control plane)
- Managed node groups
- Nginx Ingress Controller
- TLS via cert-manager
- Monitoring: Prometheus + Grafana
- Logging: Loki
- CI/CD: Jenkins → Docker → ECR → EKS
- IaC: Terraform
- Security: RBAC, IAM Roles for Service Accounts (IRSA)

## Prerequisites
- A base machine/Virtual machine for operations
- AWS account with an IAM user and access keys
- AWS CLI installed & configured on your Base Machine/Virtual Machine [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Terraform installed on your Base Machine/Virtual Machine [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform)
- VSCode Installed on your Base Machine/Virtual Machine [Install VSCode](https://code.visualstudio.com/docs/setup/linux)
- Git [Install Git](https://git-scm.com/install/linux)
- kubectl [Install Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- Helm

## Project Structure
```
eks-production-platform/
├── apps
│   └── sample-app
│       ├── deployment.yml
│       └── service.yml
├── ci-cd
│   └── Jenkinsfile
├── diagrams
│   └── architecture.png
├── kubernetes
│   ├── ingress
│   │   └── ingress.yml
│   ├── irsa
│   │   └── serviceaccount.yaml
│   ├── logging
│   │   └── values-loki.yaml
│   ├── monitoring
│   │   └── values-prometheus.yaml
│   ├── namespaces
│   │   └── namespace.yml
│   └── rbac
│       └── readonly-role.yaml
├── README.md
└── terraform
    ├── eks
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── iam
    │   ├── irsa.tf
    │   └── variables.tf
    ├── main.tf
    ├── outputs.tf
    ├── terraform.tfstate
    ├── terraform.tfstate.backup
    ├── variables.tf
    └── vpc
        ├── main.tf
        ├── outputs.tf
        └── variables.tf

```

## Clone the Repository Locally
```
git clone https://github.com/r4riyaz/Production-Grade-Kubernetes-Platform-on-AWS-EKS.git
cd Production-Grade-Kubernetes-Platform-on-AWS-EKS/eks-production-platform
```

## Step 1: Infrastructure Provisioning - VPC, EKS Cluster, IAM (IRSA)
```
cd terraform
terraform init
terraform apply
```

## Step 2: Configure kubectl
```
aws eks update-kubeconfig --region ap-south-1 --name eks-prod
kubectl get nodes
```

## Step 3: Create Service Account
```
kubectl apply -f kubernetes/irsa/serviceaccount.yaml
```
Note: How This Works
- When a pod uses:
```
serviceAccountName: app-sa
```
EKS does:
- Pod requests AWS credentials
- OIDC token is issued
- IAM role is assumed via IRSA
- Temporary credentials injected
- Pod can access AWS (S3 etc.)
No static credentials required.

## Step 4: Create Namespaces
```
kubectl apply -f kubernetes/namespaces/
```

## Step 5: Deploy Sample Application
```
kubectl apply -f apps/sample-app/
kubectl get pods -n dev
```

## Step 6: Install Ingress Controller
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install nginx ingress-nginx/ingress-nginx
```

## Step 7: Configure Ingress
```
kubectl apply -f kubernetes/ingress/
```

## Step 8: Monitoring (Prometheus & Grafana)
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

## Step 9: Logging (Loki)
```
helm repo add grafana https://grafana.github.io/helm-charts
helm install loki grafana/loki-stack -n logging --create-namespace
```

## Step 10: CI/CD Pipeline
- Jenkins builds container image
- Pushes to registry
- Deploys to EKS using kubectl
