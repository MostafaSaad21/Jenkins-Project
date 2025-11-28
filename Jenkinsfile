pipeline {
    agent any

    stages {

        stage('Checkout Code') {
            steps {
                echo "🔹 Checking out repository..."
                git branch: 'master', url: 'https://github.com/Ahmedlebshten/Jenkins-Pipeline-Build-Infra'
            }
        }

        stage('Terraform Init') {
            steps {
                echo "🔹 Initializing Terraform..."
                sh 'terraform init -reconfigure'
            }
        }

        stage('Terraform Plan') {
            steps {
                echo "🔹 Creating Terraform plan..."
                sh 'terraform plan -out=tfplan'
            }
        }

        
        stage('Terraform Apply') {
            steps {
                echo "🔹 Applying Terraform..."
                sh 'terraform apply -auto-approve tfplan'
                echo "✅ Infrastructure deployed successfully!"
            }
        }

        stage('Install ArgoCD + IAM Mapping') {
            steps {
                sh '''
                    set -e

                    export AWS_REGION=us-east-1
                    export CLUSTER_NAME=hello-devops-production-cluster

                    echo "🔹 Updating kubeconfig..."
                    aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

                    echo "🔹 Mapping Jenkins EC2 IAM Role to EKS RBAC..."
                    eksctl create iamidentitymapping \
                      --region $AWS_REGION \
                      --cluster $CLUSTER_NAME \
                      --arn arn:aws:iam::420606830171:role/Jenkins-EC2-Role \
                      --username jenkins-ec2-role \
                      --group system:masters || true

                    echo "🔹 Installing ArgoCD..."
                    kubectl create namespace argocd || true
                    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

                    echo "⏳ Waiting for ArgoCD to become ready..."
                    kubectl -n argocd wait --for=condition=Available deployment/argocd-server --timeout=300s || true

                    echo "🎉 ArgoCD Installed Successfully!"
                '''
            }
        }

        stage('Create ArgoCD Application') {
            steps {
                sh '''
                  set -e

                  export AWS_REGION=us-east-1
                  export CLUSTER_NAME=hello-devops-production-cluster

                  echo "🔹 Updating kubeconfig..."
                  aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

                  echo "🔹 Creating ArgoCD Application..."

                  kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: url-shortener
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/Ahmedlebshten/ArgoCD-Pipeline.git
    targetRevision: HEAD
    path: .
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

                  echo "🎉 ArgoCD Application Created Successfully!"
                '''
            }
        }
        
/*
        stage('Terraform Destroy') {
            steps {
                echo "🗑️ Destroying Terraform infrastructure..."
                sh 'terraform destroy -auto-approve'
                echo "🔥 Infrastructure destroyed successfully!"
            }
        }
        */
    }

    post {
        success {
            echo "🎉 Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed!"
        }
    }
}
