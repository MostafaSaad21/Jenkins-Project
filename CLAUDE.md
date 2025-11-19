# CLAUDE.md - AI Assistant Guide for HelloApp

**Last Updated:** 2025-11-19
**Repository:** HelloApp
**Type:** Infrastructure-as-Code (AWS EKS Cluster Provisioning)

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Codebase Structure](#codebase-structure)
3. [Technology Stack](#technology-stack)
4. [Development Workflows](#development-workflows)
5. [Key Conventions](#key-conventions)
6. [Common Operations](#common-operations)
7. [File Reference Guide](#file-reference-guide)
8. [Testing & Validation](#testing--validation)
9. [Deployment Process](#deployment-process)
10. [Troubleshooting](#troubleshooting)

---

## Project Overview

### What is HelloApp?

HelloApp is an **Infrastructure-as-Code (IaC)** project that provisions a complete, production-ready **AWS Elastic Kubernetes Service (EKS)** cluster with all necessary networking, security, and operational components.

### Purpose

- Automate EKS cluster provisioning using Terraform
- Provide reusable, modular infrastructure components
- Enable secure, highly-available Kubernetes environments on AWS
- Support CI/CD deployment via Jenkins

### Key Features

- **Multi-AZ High Availability** - Cluster spans multiple availability zones
- **Secure by Default** - KMS encryption, IAM roles, security groups
- **Auto-scaling** - Node groups scale between 1-4 instances
- **Modular Design** - Reusable VPC, IAM, security, and EKS modules
- **CloudWatch Integration** - Complete logging and monitoring
- **Remote State Management** - S3 backend with encryption

---

## Codebase Structure

```
HelloApp/
├── Root Module (Orchestration Layer)
│   ├── main.tf              # Root orchestration, module instantiation, aws-auth ConfigMap
│   ├── providers.tf         # AWS & Kubernetes provider configuration
│   ├── variables.tf         # Root-level input variables
│   ├── outputs.tf           # Root-level outputs (cluster endpoint, etc.)
│   ├── backend.tf           # S3 remote state configuration
│   ├── terraform.tfvars     # Default variable values (environment config)
│   └── Jenkinsfile          # CI/CD pipeline definition
│
├── modules/                 # Reusable Infrastructure Components
│   ├── vpc/                 # Networking infrastructure
│   │   ├── main.tf          # VPC, subnets, IGW, NAT, route tables
│   │   ├── variables.tf     # VPC module inputs (CIDR, AZs, etc.)
│   │   └── outputs.tf       # VPC IDs, subnet IDs, etc.
│   │
│   ├── iam/                 # Identity & Access Management
│   │   ├── main.tf          # IAM roles for cluster and nodes
│   │   ├── variables.tf     # IAM module inputs
│   │   └── outputs.tf       # IAM role ARNs
│   │
│   ├── security-groups/     # Network security
│   │   ├── main.tf          # Security groups for cluster and nodes
│   │   ├── variables.tf     # Security module inputs
│   │   └── outputs.tf       # Security group IDs
│   │
│   └── eks/                 # EKS cluster and node groups
│       ├── main.tf          # EKS cluster, node groups, KMS, logging
│       ├── variables.tf     # EKS module inputs (version, instance type, etc.)
│       └── outputs.tf       # Cluster details, endpoints, certificates
│
├── .terraform/              # Terraform working directory (gitignored)
├── .terraform.lock.hcl      # Provider version lock file
└── .gitignore               # Git ignore rules

Total: 19 Terraform files, 4 reusable modules
```

### Module Hierarchy

```
main.tf (root)
    ├── module.vpc (networking foundation)
    ├── module.iam (security roles)
    ├── module.security_groups (network security)
    └── module.eks (Kubernetes cluster)
         └── depends_on: vpc, iam, security_groups
```

---

## Technology Stack

### Infrastructure Tools

| Tool | Version | Purpose |
|------|---------|---------|
| **Terraform** | 1.0+ | Infrastructure as Code engine |
| **AWS Provider** | ~> 5.0 (locked: 5.100.0) | AWS API interactions |
| **Kubernetes Provider** | ~> 2.23 (locked: 2.38.0) | K8s resource management |

### AWS Services Used

- **EKS** - Managed Kubernetes control plane (v1.31)
- **VPC** - Virtual Private Cloud networking (10.0.0.0/16)
- **EC2** - Worker node instances (t2.micro)
- **IAM** - Identity and access management
- **KMS** - Encryption key management
- **CloudWatch** - Logging and monitoring
- **S3** - Terraform state storage (eu-west-1)

### CI/CD

- **Jenkins** - Pipeline orchestration and automation
- **GitHub** - Source code repository

---

## Development Workflows

### Standard Workflow for Infrastructure Changes

#### 1. **Make Changes**
```bash
# Edit relevant .tf files in modules/ or root
vim modules/eks/main.tf
```

#### 2. **Format Code**
```bash
terraform fmt -recursive
```

#### 3. **Validate Syntax**
```bash
terraform validate
```

#### 4. **Initialize (if providers changed)**
```bash
terraform init -reconfigure
```

#### 5. **Plan Changes**
```bash
terraform plan -out=tfplan
```

#### 6. **Review Plan Output**
- Check resources to be created/modified/destroyed
- Verify no unexpected changes
- Confirm security implications

#### 7. **Apply Changes** (when ready)
```bash
terraform apply tfplan
```

#### 8. **Commit & Push**
```bash
git add .
git commit -m "Descriptive message about infrastructure changes"
git push origin <branch-name>
```

### Jenkins Pipeline Workflow

**Current Pipeline Configuration:**

```groovy
Stage 1: Checkout Code
    ├── Clones from GitHub: mohamed55979/HelloApp
    └── Branch: main (or specified branch)

Stage 2: Terraform Init
    └── terraform init -reconfigure

Stage 3: Terraform Plan
    └── terraform plan -out=tfplan

Stage 4: Terraform Destroy
    └── terraform destroy -auto-approve
```

**Note:** The Terraform Apply stage (lines 44-60) is **currently commented out**, meaning:
- Pipeline runs planning and validation only
- No automatic deployment to AWS
- Manual apply required for infrastructure changes
- Destroy stage is active for cleanup operations

### Branch Strategy

- **Main Branch:** Not specified in git config (check with team)
- **Feature Branches:** `claude/claude-md-*` pattern for AI assistant work
- **Current Branch:** `claude/claude-md-mi6hiqj403pb3jkg-01XNvKhJrrUVsKup9a42QXBG`

---

## Key Conventions

### Naming Conventions

#### Resources
**Pattern:** `{project_name}-{environment}-{component}`

Examples:
```hcl
# EKS Cluster
"${var.project_name}-${var.environment}-cluster"
# Example: hello-devops-production-cluster

# VPC
"${var.project_name}-${var.environment}-vpc"

# IAM Roles
"${var.project_name}-${var.environment}-eks-cluster-role"
```

#### Variables
- Use **snake_case** for all variable names
- Be descriptive: `vpc_cidr_block` not `cidr`
- Environment-specific: `environment`, `project_name`

#### Tags
All resources must include:
```hcl
tags = {
  Project     = var.project_name
  Environment = var.environment
  ManagedBy   = "terraform"
  Component   = "<resource-type>"
}
```

### File Organization Conventions

#### Module Structure (Required)
Each module MUST contain:
1. `main.tf` - Resource definitions
2. `variables.tf` - Input variable declarations
3. `outputs.tf` - Output value declarations

#### Variable Ordering
In `variables.tf`:
1. Required variables (no default)
2. Optional variables (with defaults)
3. Alphabetical within each group

#### Code Formatting
- **Indentation:** 2 spaces (no tabs)
- **Line Length:** Max 120 characters recommended
- **Terraform Format:** Always run `terraform fmt` before committing
- **Comments:** Use `#` for inline comments, explain WHY not WHAT

### Security Conventions

#### IAM Principles
- **Least Privilege:** Grant minimum required permissions
- **Role-Based:** Use IAM roles, not long-term credentials
- **Service Accounts:** Dedicated roles for each service

#### Encryption Requirements
- **At Rest:** KMS encryption for EKS secrets
- **In Transit:** TLS for all API communication
- **State Files:** S3 bucket encryption enabled

#### Network Security
- **Private Subnets:** Worker nodes in private subnets only
- **Public Subnets:** Only for load balancers
- **Security Groups:** Minimal ingress rules, explicit egress

### Kubernetes Conventions

#### Node Group Configuration
- **Capacity Type:** On-Demand (production), Spot (dev/test)
- **Instance Types:** t2.micro (dev), larger for production
- **Scaling:**
  - Desired: 2
  - Min: 1
  - Max: 4

#### Labels
All node groups should have:
```hcl
labels = {
  role               = "worker"
  environment        = var.environment
  availability_zone  = <az>
}
```

---

## Common Operations

### Adding a New Module

```bash
# 1. Create module directory
mkdir -p modules/new-module

# 2. Create required files
touch modules/new-module/{main.tf,variables.tf,outputs.tf}

# 3. Define resources in main.tf
# 4. Add input variables in variables.tf
# 5. Export outputs in outputs.tf

# 6. Reference in root main.tf
# module "new_module" {
#   source = "./modules/new-module"
#   ...
# }
```

### Updating Kubernetes Version

**File:** `terraform.tfvars` (line 15)

```hcl
# Current
kubernetes_version = "1.31"

# To update
kubernetes_version = "1.32"
```

**Important:** Verify version compatibility in AWS EKS documentation before upgrading.

### Adding IAM Users for Cluster Access

**File:** `terraform.tfvars` (lines 17-27)

```hcl
iam_users = [
  {
    userarn  = "arn:aws:iam::123456789012:user/newuser"
    username = "newuser"
    groups   = ["system:masters"]  # or appropriate group
  }
]
```

**After changes:** Reapply to update aws-auth ConfigMap.

### Modifying VPC CIDR or Subnets

**File:** `terraform.tfvars` (lines 4-9)

```hcl
vpc_cidr_block      = "10.0.0.0/16"        # Main VPC CIDR
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
```

**Warning:** Changing CIDR blocks on existing infrastructure requires careful planning.

### Changing Node Instance Type

**File:** `terraform.tfvars` (line 12)

```hcl
# Development
node_instance_type = "t2.micro"

# Production (recommended)
node_instance_type = "t3.medium"
```

### Enabling/Disabling CloudWatch Logs

**File:** `modules/eks/main.tf` (lines 19-25)

```hcl
enabled_cluster_log_types = [
  "api",
  "audit",
  "authenticator",
  "controllerManager",
  "scheduler"
]

# To disable specific logs, remove from list
# To disable all: enabled_cluster_log_types = []
```

---

## File Reference Guide

### Critical Files (Read First)

| File | Lines | Purpose | When to Modify |
|------|-------|---------|----------------|
| `terraform.tfvars` | 29 | **Environment configuration** - All deployment parameters | Changing environment settings, scaling, versions |
| `main.tf` | 57 | **Root orchestration** - Modules instantiation and aws-auth | Adding/removing modules, IAM access changes |
| `Jenkinsfile` | 88 | **CI/CD pipeline** - Automated deployment | Modifying pipeline stages, adding deployment steps |
| `providers.tf` | 32 | **Provider configuration** - AWS and K8s setup | Changing AWS region, provider versions |

### Module Files (By Module)

#### VPC Module (`modules/vpc/`)
- **main.tf** (155 lines) - VPC, subnets, gateways, routing
- **variables.tf** (48 lines) - CIDR blocks, AZ configuration
- **outputs.tf** (21 lines) - VPC ID, subnet IDs for other modules

**Key Resources:**
- `aws_vpc.main` - Main VPC (line 2-9)
- `aws_subnet.public` - Public subnets (line 15-29)
- `aws_subnet.private` - Private subnets (line 35-49)
- `aws_nat_gateway.main` - NAT gateway for private subnet egress (line 67-73)

#### IAM Module (`modules/iam/`)
- **main.tf** (70 lines) - IAM roles and policy attachments
- **variables.tf** (15 lines) - Project and environment names
- **outputs.tf** (9 lines) - Role ARNs

**Key Resources:**
- `aws_iam_role.eks_cluster_role` - EKS cluster IAM role (line 2-15)
- `aws_iam_role.eks_node_role` - Worker node IAM role (line 27-40)

#### Security Groups Module (`modules/security-groups/`)
- **main.tf** (81 lines) - Security group rules
- **variables.tf** (35 lines) - VPC ID, allowed IPs
- **outputs.tf** (9 lines) - Security group IDs

**Key Resources:**
- `aws_security_group.cluster_sg` - Cluster control plane SG (line 2-14)
- `aws_security_group.node_sg` - Worker node SG (line 43-55)

#### EKS Module (`modules/eks/`)
- **main.tf** (133 lines) - EKS cluster and node groups
- **variables.tf** (125 lines) - All EKS configuration parameters
- **outputs.tf** (25 lines) - Cluster details, endpoints

**Key Resources:**
- `aws_kms_key.eks_secrets` - KMS key for secrets encryption (line 2-8)
- `aws_eks_cluster.main` - EKS cluster resource (line 12-35)
- `aws_cloudwatch_log_group.eks_cluster` - CloudWatch logging (line 38-43)
- `aws_eks_node_group.main` - Worker node groups (line 46-87)

### Configuration Files

| File | Purpose | Git Tracked |
|------|---------|-------------|
| `backend.tf` | S3 remote state configuration | Yes |
| `.terraform.lock.hcl` | Provider version locks | Yes |
| `.gitignore` | Git ignore rules | Yes |
| `terraform.tfstate` | Current infrastructure state | **No** (remote only) |
| `terraform.tfstate.backup` | Previous state backup | **No** |
| `.terraform/` | Provider plugins and modules | **No** |

---

## Testing & Validation

### Pre-Apply Validation

#### 1. Format Check
```bash
terraform fmt -check -recursive
```
**Expected:** No output (all files formatted)
**If fails:** Run `terraform fmt -recursive` to fix

#### 2. Syntax Validation
```bash
terraform validate
```
**Expected:** "Success! The configuration is valid."

#### 3. Plan Review
```bash
terraform plan -out=tfplan
```
**Review checklist:**
- [ ] No unexpected resource deletions
- [ ] Security group changes don't expose services
- [ ] IAM policy changes follow least privilege
- [ ] No hardcoded credentials or secrets
- [ ] Resource naming follows conventions
- [ ] All resources properly tagged

### Post-Apply Validation

#### 1. Cluster Access Test
```bash
aws eks update-kubeconfig --region eu-west-1 --name <cluster-name>
kubectl get nodes
```
**Expected:** List of nodes in Ready state

#### 2. Node Group Health
```bash
kubectl get nodes -o wide
```
**Check:**
- All nodes in Ready status
- Correct instance types
- Distributed across AZs

#### 3. AWS Resources
```bash
# Verify VPC
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=<project>"

# Verify EKS cluster
aws eks describe-cluster --name <cluster-name> --region eu-west-1

# Verify node groups
aws eks list-nodegroups --cluster-name <cluster-name> --region eu-west-1
```

### Automated Testing (Not Currently Implemented)

**Recommendations for future implementation:**
- **Terraform Linting:** `tflint` for static analysis
- **Policy Validation:** Terraform Cloud Sentinel policies
- **Security Scanning:** `checkov` or `tfsec` for security issues
- **Integration Tests:** Terratest for automated validation

---

## Deployment Process

### Local Deployment (Manual)

```bash
# 1. Ensure AWS credentials configured
aws configure list

# 2. Initialize Terraform
terraform init -reconfigure

# 3. Select/create workspace (if using workspaces)
terraform workspace select production
# or
terraform workspace new production

# 4. Plan infrastructure changes
terraform plan -out=tfplan

# 5. Review plan output carefully
# READ THE ENTIRE PLAN before applying

# 6. Apply changes
terraform apply tfplan

# 7. Save outputs (optional)
terraform output > outputs.txt
```

### Jenkins Pipeline Deployment

**Current State:** Apply stage is **commented out** (Jenkinsfile:44-60)

**To enable automated deployment:**

1. Uncomment lines 44-60 in Jenkinsfile
2. Ensure Jenkins has AWS credentials configured
3. Configure approval step if required
4. Push changes to trigger pipeline

**Pipeline stages:**
```
Checkout → Init → Plan → [Apply] → [Destroy]
```

### Backend State Management

**Configuration:** `backend.tf`

```hcl
bucket         = "hello-devops-production-terraform-state"
key            = "eks/terraform.tfstate"
region         = "eu-west-1"
encrypt        = true
```

**Important:**
- State file contains sensitive data (encrypted in S3)
- Never commit `terraform.tfstate` to Git
- State locking prevents concurrent modifications
- Manual state edits should be avoided

### Rollback Procedures

#### Terraform Rollback
```bash
# 1. List state backups
ls -la terraform.tfstate.backup*

# 2. Restore previous state (dangerous!)
cp terraform.tfstate.backup terraform.tfstate

# 3. Or use S3 versioning
aws s3api list-object-versions \
  --bucket hello-devops-production-terraform-state \
  --prefix eks/terraform.tfstate
```

#### Git Rollback
```bash
# Revert to previous commit
git revert <commit-hash>
git push origin <branch>

# Re-run terraform plan/apply with reverted code
```

---

## Troubleshooting

### Common Issues

#### Issue: "Error acquiring the state lock"

**Cause:** Another process is running Terraform or previous run didn't clean up

**Solution:**
```bash
# Check DynamoDB for lock (if configured)
# Or wait for timeout (usually 2 minutes)

# Force unlock (use with caution!)
terraform force-unlock <lock-id>
```

#### Issue: "Provider version constraint not met"

**Cause:** `.terraform.lock.hcl` has different version than required

**Solution:**
```bash
# Update providers to match constraints
terraform init -upgrade

# Or lock to specific version
terraform providers lock
```

#### Issue: "VPC CIDR conflicts with existing"

**Cause:** VPC CIDR overlaps with existing VPC in AWS account

**Solution:**
```hcl
# Change CIDR in terraform.tfvars
vpc_cidr_block = "10.1.0.0/16"  # Use non-overlapping range
```

#### Issue: "Insufficient capacity" (EC2)

**Cause:** AWS doesn't have requested instance type in AZ

**Solution:**
```hcl
# Try different instance type
node_instance_type = "t3.small"

# Or different availability zones
availability_zones = ["eu-west-1a", "eu-west-1c"]
```

#### Issue: "Kubernetes version not supported"

**Cause:** Specified Kubernetes version not available in EKS

**Solution:**
```bash
# Check supported versions
aws eks describe-addon-versions --region eu-west-1

# Update terraform.tfvars to supported version
kubernetes_version = "1.31"  # Use supported version
```

### Debugging Tips

#### Enable Terraform Debug Logging
```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform-debug.log
terraform plan
```

#### Check AWS CloudWatch Logs
```bash
# View EKS cluster logs
aws logs tail /aws/eks/<cluster-name>/cluster --follow --region eu-west-1
```

#### Verify IAM Permissions
```bash
# Test AWS credentials
aws sts get-caller-identity

# Check IAM user/role permissions
aws iam get-user
aws iam list-attached-user-policies --user-name <username>
```

#### Inspect Terraform State
```bash
# List all resources in state
terraform state list

# Show specific resource
terraform state show module.eks.aws_eks_cluster.main

# Validate state
terraform validate
```

---

## AI Assistant Best Practices

### When Making Changes

1. **Always read files before editing** - Use Read tool first
2. **Understand dependencies** - Check module references in root main.tf
3. **Validate changes** - Run `terraform fmt` and `terraform validate`
4. **Check for sensitive data** - Never commit secrets or credentials
5. **Follow naming conventions** - Use established patterns
6. **Update this file** - Keep CLAUDE.md current with significant changes

### When Answering Questions

1. **Reference specific files and line numbers** - e.g., "modules/eks/main.tf:45"
2. **Explain WHY not just WHAT** - Provide context for decisions
3. **Consider AWS best practices** - Security, cost, reliability
4. **Check current state** - Read files to verify before answering

### When Troubleshooting

1. **Read error messages carefully** - They often contain the solution
2. **Check recent git history** - What changed recently?
3. **Verify AWS service limits** - May be account/region specific
4. **Review CloudWatch logs** - Real-time debugging information

### Red Flags to Watch For

- ❌ Hardcoded credentials or secrets in .tf files
- ❌ Security groups with 0.0.0.0/0 ingress on sensitive ports
- ❌ Unencrypted S3 buckets or EBS volumes
- ❌ IAM policies with wildcards (*) in production
- ❌ Missing tags on resources
- ❌ Terraform state committed to Git
- ❌ Provider version changes without lock file update

---

## Additional Resources

### Terraform Documentation
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

### AWS EKS Documentation
- [EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Kubernetes Versions](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html)

### Repository Information
- **GitHub:** https://github.com/mohamed55979/HelloApp
- **Current Branch:** claude/claude-md-mi6hiqj403pb3jkg-01XNvKhJrrUVsKup9a42QXBG
- **Latest Commit:** b893f8d "Update Jenkinsfile"

---

## Changelog

### 2025-11-19 - Initial Creation
- Created comprehensive CLAUDE.md documentation
- Documented all 4 modules (VPC, IAM, Security Groups, EKS)
- Added development workflows and conventions
- Included troubleshooting guide
- Documented current state: K8s 1.31, Jenkins pipeline with apply commented out

---

**For questions or updates to this document, modify CLAUDE.md and update the changelog.**
