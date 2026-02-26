provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "drink-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name : "drink-vpc"
  }
}

# Subnets (2 public subnets)
resource "aws_subnet" "drink-subnet" {
  vpc_id = aws_vpc.drink-vpc.id
  count = 2
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
  cidr_block = cidrsubnet(aws_vpc.drink-vpc.cidr_block,8,count.index)
  map_public_ip_on_launch = true
  tags = {
    Name: "drink-subnet-${count.index}"
  }
}

resource "aws_route_table" "drink-rt" {
  vpc_id = aws_vpc.drink-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.drink-igw.id
  }
  tags = {
    Name:"drink-rt"
  }
}

resource "aws_internet_gateway" "drink-igw" {
  vpc_id = aws_vpc.drink-vpc.id

  tags ={
    Name:"drink-igw"
  }
}

resource "aws_route_table_association" "drink-rtas" {
  count = 2
  route_table_id = aws_route_table.drink-rt.id
  subnet_id = aws_subnet.drink-subnet[count.index].id
}

resource "aws_security_group" "drink-cluster-sg" {
  name = drink-cluster-sg
  vpc_id = aws_vpc.drink-vpc.id
   egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "drink-work-node-sg" {
  name = drink-work-node-sg
  vpc_id = aws_vpc.drink-vpc.id
   ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "drink_eks_cluster_role" {
  name = "drink_eks_cluster_role"

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

resource "aws_iam_role_policy_attachment" "cluster_policy" {
    role = aws_iam_role.drink_eks_cluster_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

############################
# IAM Role - Worker Nodes
############################
resource "aws_iam_role" "drink_eks_node_role" {
  name = "drink_eks_node_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cni-policy" {
  role = aws_iam_role.drink_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
resource "aws_iam_role_policy_attachment" "container-policy" {
  role = aws_iam_role.drink_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "node-policy" {
  role = aws_iam_role.drink_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# EKS Cluster

resource "aws_eks_cluster" "drink-cluster" {
  name = "drink-cluster"
  role_arn = aws_iam_role.drink_eks_cluster_role.arn

  vpc_config{
    subnet_ids = aws_subnet.drink-subnet[*].id
    security_group_ids = [aws_security_group.drink-cluster-sg.id]
  } 

  depends_on = [ 
    aws_iam_role_policy_attachment.cluster_policy
   ]
}

# EKS Node Group

resource "aws_eks_node_group" "drink-node-group" {
  cluster_name = aws_eks_cluster.drink-cluster.name
  node_group_name = "drink-node-group"
  node_role_arn = aws_iam_role.drink_eks_node_role.arn

  subnet_ids = aws_subnet.drink-subnet[*].id
 

   scaling_config {
     min_size = 3
     max_size = 50
     desired_size = 3
   }

   instance_types = ["m7i-flex.large"]

    remote_access {
    ec2_ssh_key               = var.key-pair
    source_security_group_ids = [aws_security_group.drink-work-node-sg.id]
  }

  depends_on = [
  aws_iam_role_policy_attachment.cni-policy,
  aws_iam_role_policy_attachment.container-policy,
  aws_iam_role_policy_attachment.node-policy
]
}

