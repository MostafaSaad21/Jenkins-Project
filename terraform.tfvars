# ============================================================================
# PROJECT CONFIGURATION
# ============================================================================
project_name = "my-eks-project"
environment  = "dev"
aws_region   = "us-east-1"

# ============================================================================
# VPC CONFIGURATION
# ============================================================================
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
enable_nat_gateway   = true
single_nat_gateway   = false
enable_dns_hostnames = true
enable_dns_support   = true

# ============================================================================
# EKS CONFIGURATION
# ============================================================================
cluster_version           = "1.30"
node_group_desired_size   = 2
node_group_min_size       = 1
node_group_max_size       = 4
node_instance_types       = ["t2.micro"]
node_disk_size            = 20
enable_cluster_encryption = true
cluster_log_types         = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

# ============================================================================
# SECURITY CONFIGURATION
# ============================================================================
allowed_ssh_ips = ["0.0.0.0/0"]  # Replace with your IP for production

# ============================================================================
# IAM ACCESS CONFIGURATION - Grant Console Access
# ============================================================================
# Add your IAM user ARN here (get it with: aws sts get-caller-identity)
additional_iam_users = [
  {
    userarn  = "arn:aws:iam::742674388365:user/cli-user"  # REPLACE THIS
    username = "cli-user"
    groups   = ["system:masters"]
  }
]

# If you use IAM roles (SSO, assumed roles), add them here
additional_iam_roles = [
  # Uncomment and modify if needed:
  # {
  #   rolearn  = "arn:aws:iam::123456789012:role/YourRoleName"
  #   username = "admin-role"
  #   groups   = ["system:masters"]
  # }
]

# ============================================================================
# TAGS
# ============================================================================
tags = {
  Project     = "EKS-Infrastructure"
  Environment = "dev"
  ManagedBy   = "Terraform"
  Owner       = "DevOps-Team"
}
