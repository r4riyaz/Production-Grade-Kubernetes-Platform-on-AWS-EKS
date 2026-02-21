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
- AWS CLI, Terraform, VSCode, Git, Kubectl, Helm installed & configured on your Base Machine/Virtual Machine. Refer below links
    - [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
    - [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform)
    - [Install VSCode](https://code.visualstudio.com/docs/setup/linux)
    - [Install Git](https://git-scm.com/install/linux)
    - [Install Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
    - [Install Helm](https://helm.sh/docs/intro/install/#from-script)

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

## Step 1: Clone the Repository Locally
```
git clone https://github.com/r4riyaz/Production-Grade-Kubernetes-Platform-on-AWS-EKS.git
cd Production-Grade-Kubernetes-Platform-on-AWS-EKS/eks-production-platform
```

## Step 2: Infrastructure Provisioning - VPC, EKS Cluster, IAM (IRSA)
```
cd eks-production-platform/terraform
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
kubectl apply -f eks-production-platform/kubernetes/namespaces/namespace.yml
kubectl get ns
```

## Step 5: Create Service Account
```
kubectl apply -f eks-production-platform/kubernetes/irsa/serviceaccount.yaml
kubectl get sa -n dev
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

## Step 6: Deploy Sample Application
```
kubectl apply -f eks-production-platform/apps/sample-app/
kubectl get deployments -n dev
kubectl get pods -n dev
```

## Step 7: Install Ingress Controller
Make sure you have latest helm installed and wait for the load balancer IP to be available.
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install nginx ingress-nginx/ingress-nginx
kubectl get service nginx-ingress-nginx-controller --output wide
```

## Step 8: Deploy Ingress Resource
```
kubectl apply -f kubernetes/ingress/
kubectl get ingress -n dev
```
Now there are multiple options to access application.
- Via CLI
  ```
  curl -H "Host: nginx.example.com" http://<ELB-DNS>
  ```
- Use /etc/hosts file & visit the URL in browser. (Recommended for Local Testing)
  ```
  <ELB-IP> nginx.example.com
  ```
- Instead of /etc/hosts
    - Buy or Use a Domain
      Example: mydomain.com
    - Create Route53 Record
        Type: CNAME
        Name: nginx
        Value: <ELB-DNS>
    - Open browser and visit http://nginx.mydomain.com

- Final Traffic Flow (Browser Working Version)
```
Browser
   ↓
DNS resolves nginx.example.com
   ↓
AWS ELB
   ↓
NGINX Ingress Controller
   ↓
nginx-svc
   ↓
nginx pods
```

## Step 9: .....is in progress and will be added soon
