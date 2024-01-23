# Define the provider block for AWS
provider "aws" {
  region = "us-east-1"  # Update with your desired AWS region
}

# Create the VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"  # Update with your desired VPC CIDR block

  tags = {
    Name = "eks-vpc"
  }
}

# Create the EKS cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "my-eks-cluster"  # Update with your desired cluster name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.eks_subnet.id]  # Update with your desired subnet IDs

    # If you want to create a public and private cluster, uncomment the lines below
    # public_access_cidrs = ["0.0.0.0/0"]
    # endpoint_private_access = true
    # endpoint_public_access = true
  }
}

# Create the IAM role for the EKS cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach the necessary policies to the EKS cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Create the subnet for the EKS cluster
resource "aws_subnet" "eks_subnet" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.1.0/24"  # Update with your desired subnet CIDR block
  availability_zone       = "us-east-1a"   # Update with your desired availability zone
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-subnet"
  }
}

# Output the EKS cluster name and endpoint
output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}
