# ELK Learning Lab with Terraform

This Terraform setup creates:

- 1 Ubuntu EC2 instance for your application
- 1 Ubuntu EC2 instance for ELK stack
- Security groups with common ports for app + ELK
- A dedicated VPC, public subnet, internet gateway, and route table (no default VPC dependency)

Both instances are tagged so you can cleanly remove everything with `terraform destroy`.

## Open ports

Application instance (`app`):

- `22` (SSH)
- `80` (HTTP)
- `443` (HTTPS)

ELK instance (`elk`):

- `22` (SSH)
- `5601` (Kibana)
- `9200` (Elasticsearch HTTP)
- `5044` (Logstash Beats input)

## Prerequisites

- Terraform installed (`>= 1.5`)
- AWS CLI configured and authenticated (already done by you)

## Usage

1. Initialize Terraform:

   ```bash
   terraform init
   ```

2. Create your variables file:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. (Recommended) Edit `terraform.tfvars` and lock `*_allowed_cidrs` to your own public IP as `/32`.

4. Preview resources and save a plan file:

   ```bash
   terraform plan -out=tfplan
   ```

5. Create resources from the saved plan:

   ```bash
   terraform apply tfplan
   ```

6. SSH into instances (after apply):

   ```bash
   ssh -i /Users/vijay/.ssh/aws-elk-stack ubuntu@<app-public-ip>
   ssh -i /Users/vijay/.ssh/aws-elk-stack ubuntu@<elk-public-ip>
   ```

7. When done learning, destroy everything:

   ```bash
   terraform destroy
   ```

## Notes

- Default instance type is `t3.large` for a moderately powerful lab setup.
- ELK instance uses an `80 GB` root disk; app instance uses `30 GB`.
- By default, Terraform creates an EC2 key pair named `aws-elk-stack` from `/Users/vijay/.ssh/aws-elk-stack.pub`.
- If you already have an AWS key pair, set `key_name` in `terraform.tfvars` and it will be used instead.
- Networking is fully managed by Terraform (dedicated VPC/subnet/IGW/route table), so no default VPC is required in your AWS account.
