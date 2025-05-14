variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.medium"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  default     = "my-key-pair"
}
