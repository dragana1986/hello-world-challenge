# Tech Challenge 2 — Containerized App on EKS with CI/CD (Jenkins) and GitOps (GitHub Actions + Argo CD)

A "Hello, World!" Flask web application, containerized with Docker, stored in Amazon ECR, and
deployed to an auto-scaling **AWS EKS** cluster provisioned entirely with **Terraform** (modules +
remote state). Two CI/CD approaches are implemented:

- **`main` branch** — a **Jenkins** pipeline (build → push to ECR → deploy with Helm).
- **`gitops` branch** — **GitHub Actions** (build → push) + **Argo CD** (pull-based deploy).

**Live application URL:** `http://k8s-default-hellowor-75ebf6ac54-1743320528.us-east-1.elb.amazonaws.com`

---

## Architecture

```
 git push ─▶ GitHub ─▶ CI (Jenkins OR GitHub Actions) ─▶ build image ─▶ Amazon ECR
                                                                          │
   main:  Jenkins runs `helm upgrade`  ────────────────────────────────┐  │ pull
   gitops: Actions bumps image tag in git ─▶ Argo CD syncs ────────────┤  ▼
                                                                        ▼
                                                     AWS EKS cluster (Terraform)
                                                     ├─ 1–4 × t3.small nodes (auto-scaling)
                                                     ├─ HPA: 50% CPU / 50% memory
                                                     └─ ALB (public URL) via AWS LB Controller
```

## Repository layout

```
.
├─ app/                       # Flask app + Dockerfile (gunicorn, non-root user)
├─ helm/hello-world/          # Helm chart: Deployment, Service, Ingress (ALB), HPA
├─ terraform/
│  ├─ bootstrap/              # S3 bucket + DynamoDB lock table for remote state
│  ├─ modules/{network,eks,ecr}/   # reusable modules
│  └─ envs/dev/               # environment root: wires modules + S3 backend
├─ argocd/application.yaml    # Argo CD Application (gitops branch)
├─ .github/workflows/ci.yml   # GitHub Actions CI (gitops branch)
├─ Jenkinsfile                # Jenkins pipeline (main branch)
└─ README.md
```

## Prerequisites

- AWS account + IAM user with programmatic access (`aws configure`)
- Tools: `awscli`, `terraform`, `kubectl`, `helm`, `docker`, `git`
- Region used throughout: **us-east-1**

## Setup & deployment

### 1. Terraform remote state (bootstrap — run once)
```bash
cd terraform/bootstrap
terraform init
terraform apply -var="state_bucket_name=<globally-unique-bucket-name>"
```
Creates the S3 bucket (versioned + encrypted) and DynamoDB lock table used as the backend.

### 2. Provision the infrastructure (VPC, EKS, ECR)
```bash
cd terraform/envs/dev
terraform init      # configures the S3 backend
terraform apply     # VPC + EKS (~10–15 min) + ECR
aws eks update-kubeconfig --region us-east-1 --name hello-world-cluster
kubectl get nodes
```

### 3. Build and push the image
```bash
$repo = aws ecr describe-repositories --region us-east-1 --query "repositories[0].repositoryUri" --output text
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $repo
docker build -t "${repo}:v1" ./app
docker push "${repo}:v1"
```

### 4. Install the AWS Load Balancer Controller (for the public ALB)
Provisioned via IRSA (`terraform/envs/dev`), then:
```bash
helm repo add eks https://aws.github.io/eks-charts && helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system \
  --set clusterName=hello-world-cluster \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set "serviceAccount.annotations.eks\.amazonaws\.com/role-arn=<lb_controller_role_arn>"
```

### 5. Deploy the app + autoscaling
```bash
helm upgrade --install hello-world ./helm/hello-world
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl get ingress   # ADDRESS = public ALB URL
kubectl get hpa
```

## The Terraform code

- **`bootstrap/`** creates the remote-state backend (S3 + DynamoDB) — a separate, minimal config with
  local state that solves the chicken-and-egg problem of storing state in S3.
- **`modules/network`** wraps the community VPC module: a VPC across 2 AZs with public + private
  subnets, a NAT gateway, and the `kubernetes.io/role/elb` subnet tags EKS needs for load balancers.
- **`modules/eks`** wraps the community EKS module: managed node group (`t3.small`, min 1 / max 4),
  IRSA/OIDC enabled, and the creator granted cluster-admin.
- **`modules/ecr`** creates the image repository with scan-on-push.
- **`envs/dev`** is the environment root — it wires the modules together and uses the S3 backend.
  Node **count** is managed via the EKS API/autoscaler (the EKS module intentionally ignores
  `desired_size`).

## CI/CD — Jenkins (`main` branch)

`Jenkinsfile` defines a pipeline with four stages: **Checkout → Build image → Push to ECR → Deploy
to EKS** (`helm upgrade --install`). Each build tags the image `v${BUILD_NUMBER}`. Jenkins runs as a
container with the Docker socket and `~/.aws` mounted; a GitHub PAT (stored in Jenkins credentials)
pulls the repo. Trigger with **Build Now**.

## GitOps — GitHub Actions + Argo CD (`gitops` branch)

- **`.github/workflows/ci.yml`** builds the image, pushes it to ECR (tagged with the commit SHA), and
  commits the new tag into `helm/hello-world/values.yaml`. AWS creds come from repo secrets.
- **`argocd/application.yaml`** defines an Argo CD Application that watches the `gitops` branch at
  `helm/hello-world` and **auto-syncs** (prune + self-heal) into the `hello-world-gitops` namespace.

The result is pull-based delivery: CI only updates git; Argo CD reconciles the cluster to match.

## EKS specifics (per the brief)

- Nodes: `t3.small`, **min 1 / max 4** (auto-scaling), one baseline pod per node.
- **HPA**: scales pods on **50% CPU or 50% memory** utilization (requires metrics-server + pod
  resource requests, both configured in the chart).
- **ALB**: internet-facing, provisioned by the AWS Load Balancer Controller from a Kubernetes Ingress.

## Cleanup (avoid ongoing AWS charges)

```bash
helm uninstall hello-world
kubectl delete -f argocd/application.yaml
cd terraform/envs/dev && terraform destroy
cd ../../bootstrap    && terraform destroy   # optional: also remove the state backend
```

---
*Built as part of Tech Challenge 2. See the accompanying guide for a step-by-step build log,
troubleshooting notes, and design rationale.*