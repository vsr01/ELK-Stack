variable "aws_region" {
  description = "AWS region where resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix for resource names and tags."
  type        = string
  default     = "elk-lab"
}

variable "instance_type" {
  description = "EC2 instance type for both app and ELK instances."
  type        = string
  default     = "t3.large"
}

variable "key_name" {
  description = "Existing EC2 key pair name. If null, Terraform creates one from public_key_path."
  type        = string
  default     = null
}

variable "public_key_path" {
  description = "Path to your local SSH public key used to create an EC2 key pair when key_name is null."
  type        = string
  default     = "/Users/vijay/.ssh/aws-elk-stack.pub"
}

variable "managed_key_pair_name" {
  description = "Name of the EC2 key pair Terraform creates when key_name is null."
  type        = string
  default     = "aws-elk-stack"
}

variable "vpc_cidr" {
  description = "CIDR block for the lab VPC."
  type        = string
  default     = "10.42.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet where both instances are placed."
  type        = string
  default     = "10.42.1.0/24"
}

variable "app_allowed_cidrs" {
  description = "CIDR blocks allowed to access the application instance."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "elk_allowed_cidrs" {
  description = "CIDR blocks allowed to access ELK web ports from your workstation."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to SSH into both instances."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
