#!/usr/bin/env bash
# Regenerates ansible/inventory.ini from current Terraform outputs.
# Usage: ./scripts/update-inventory.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
TF_DIR="$REPO_ROOT/terraform"
INVENTORY="$REPO_ROOT/ansible/inventory.ini"

echo "Reading Terraform outputs from $TF_DIR ..."

APP_IP=$(terraform -chdir="$TF_DIR" output -raw app_instance_public_ip)
ELK_IP=$(terraform -chdir="$TF_DIR" output -raw elk_instance_public_ip)

# Derive ELK private IP from tfstate (used for internal Filebeat → Logstash comms)
ELK_PRIVATE_IP=$(terraform -chdir="$TF_DIR" show -json \
  | python3 -c "
import sys, json
state = json.load(sys.stdin)
for r in state.get('values', {}).get('root_module', {}).get('resources', []):
    if r.get('type') == 'aws_instance' and r.get('name') == 'elk':
        print(r['values']['private_ip'])
        break
")

echo "  app public IP  : $APP_IP"
echo "  elk public IP  : $ELK_IP"
echo "  elk private IP : $ELK_PRIVATE_IP"

cat > "$INVENTORY" <<EOF
[app]
app-server ansible_host=${APP_IP} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/aws-elk-stack

[elk]
elk-server ansible_host=${ELK_IP} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/aws-elk-stack

[all:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
elk_private_ip=${ELK_PRIVATE_IP}
EOF

echo "Inventory written to $INVENTORY"
