# Production-Grade Kubernetes Platform on AWS (EKS)
<sub>Note: Still in testing phase...</sub>

## Overview
This project demonstrates the design, deployment, and operation of a
production-grade Kubernetes platform on AWS using EKS. The focus is on
reliability, security, observability, and automation.

## Architecture
- AWS VPC (3 AZ)
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
- AWS CLI installed & configured on your Base Machine/Virtual Machine [Install AWS CLI](https://docs.aws.amazon.com/cli/v1/userguide/install-linux.html)
- Terraform installed on your Base Machine/Virtual Machine [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform)
- VSCode Installed on your Base Machine/Virtual Machine [Install VSCode](https://code.visualstudio.com/docs/setup/linux)
- kubectl
- Helm

## Project Structure
```

eks-production-platform/
├── terraform/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── eks/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── iam/
│       └── irsa.tf
├── kubernetes/
│   ├── namespaces/
│   │   └── namespaces.yaml
│   ├── rbac/
│   │   └── readonly-role.yaml
│   ├── ingress/
│   │   └── ingress.yaml
│   ├── monitoring/
│   │   └── values-prometheus.yaml
│   └── logging/
│       └── values-loki.yaml
├── apps/
│   └── sample-app/
│       ├── deployment.yaml
│       └── service.yaml
├── ci-cd/
│   └── Jenkinsfile
├── diagrams/
│   └── architecture.png
└── README.md

```
## Clone the Repository Locally
```
git clone https://github.com/r4riyaz/Production-Grade-Kubernetes-Platform-on-AWS-EKS.git
cd Production-Grade-Kubernetes-Platform-on-AWS-EKS/eks-production-platform
```

## Step 1: Infrastructure Provisioning
```
cd terraform/vpc
terraform init
terraform apply
```

## Step 2: Provision EKS Cluster
```
cd terraform/eks
terraform init
terraform apply
```

## Step 3: Configure kubectl
```
aws eks update-kubeconfig --region ap-south-1 --name eks-prod
kubectl get nodes
```

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
