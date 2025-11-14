resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = "arn:aws:iam::742674388365:role/hello-devops-production-eks-node-role"
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }
    ])
    mapUsers = yamlencode([
      {
        userarn  = "arn:aws:iam::742674388365:user/cli-user" # your IAM user
        username = "cli-user"
        groups   = ["system:masters"]
      },
      {
        userarn  = "arn:aws:iam::742674388365:root"
        username = "root"
        groups   = ["system:masters"]
      }
    ])
  }
}
