output "app_instance_public_ip" {
  description = "Public IP of the application EC2 instance."
  value       = aws_instance.app.public_ip
}

output "elk_instance_public_ip" {
  description = "Public IP of the ELK EC2 instance."
  value       = aws_instance.elk.public_ip
}

output "ssh_examples" {
  description = "SSH examples for both instances."
  value = {
    app = "ssh ubuntu@${aws_instance.app.public_ip}"
    elk = "ssh ubuntu@${aws_instance.elk.public_ip}"
  }
}

output "effective_key_pair_name" {
  description = "EC2 key pair attached to instances."
  value       = var.key_name != null ? var.key_name : aws_key_pair.lab[0].key_name
}
