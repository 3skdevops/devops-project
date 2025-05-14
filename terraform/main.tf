 provider "aws" { region = var.aws_region }
 # VPC
 resource "aws_vpc" "main" {
   cidr_block = "10.0.0.0/16"
   enable_dns_support   = true
   enable_dns_hostnames = true
   tags = {
     Name = "devops-vpc"
   }
 }

 # Subnets
 resource "aws_subnet" "public" {
   vpc_id            = aws_vpc.main.id
   cidr_block        = "10.0.1.0/24"
   availability_zone = "${var.aws_region}a"
   map_public_ip_on_launch = true
   tags = {
     Name = "public-subnet"
   }
 }

 # Internet Gateway
 resource "aws_internet_gateway" "gw" {
   vpc_id = aws_vpc.main.id
   tags = {
     Name = "devops-igw"
   }
 }

 # Route Table
 resource "aws_route_table" "public" {
   vpc_id = aws_vpc.main.id
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.gw.id
   }
   tags = {
     Name = "public-route-table"
   }
 }

 resource "aws_route_table_association" "public" {
   subnet_id      = aws_subnet.public.id
   route_table_id = aws_route_table.public.id
 }

 # Security Group for Kubernetes
 resource "aws_security_group" "k8s_sg" {
   vpc_id = aws_vpc.main.id
   ingress {
     from_port   = 0
     to_port     = 65535
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   egress {
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
   }
   tags = {
     Name = "k8s-sg"
   }
 }

 # Security Group for Jenkins
 resource "aws_security_group" "jenkins_sg" {
   vpc_id = aws_vpc.main.id
   ingress {
     from_port   = 8080
     to_port     = 8080
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   egress {
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
   }
   tags = {
     Name = "jenkins-sg"
   }
 }

 # EC2 Instances for Kubernetes Nodes
 resource "aws_instance" "k8s_node" {
   count         = 3
   ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI (update for your region)
   instance_type = var.instance_type
   subnet_id     = aws_subnet.public.id
   security_groups = [aws_security_group.k8s_sg.name]
   key_name      = var.key_name
   tags = {
     Name = "k8s-node-${count.index}"
   }
 }

 # EC2 Instance for Jenkins
 resource "aws_instance" "jenkins" {
   ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
   instance_type = var.instance_type
   subnet_id     = aws_subnet.public.id
   security_groups = [aws_security_group.jenkins_sg.name]
   key_name      = var.key_name
   tags = {
     Name = "jenkins-server"
   }
 }