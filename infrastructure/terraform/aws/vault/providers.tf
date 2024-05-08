provider "kubernetes" {
  host                   = data.aws_eks_cluster.icmc.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.icmc.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", var.cluster_id]
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.icmc.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.icmc.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", var.cluster_id]
    }
  }
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.icmc.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.icmc.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", var.cluster_id]
  }
}
