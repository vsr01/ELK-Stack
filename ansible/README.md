# ELK Lab — Ansible Playbooks

## Prerequisites

Install Ansible on your local machine:
```bash
pip install ansible
```

## Structure

```
ansible/
├── ansible.cfg       # default settings (inventory, key, etc.)
├── inventory.ini     # app + elk hosts with IPs from Terraform
├── site.yml          # runs elk.yml then app.yml
├── elk.yml           # installs Elasticsearch, Kibana, Logstash
└── app.yml           # installs nginx + Filebeat
```

## Running

**Full setup (both instances):**
```bash
cd ansible
ansible-playbook site.yml
```

**ELK instance only:**
```bash
ansible-playbook elk.yml
```

**App instance only:**
```bash
ansible-playbook app.yml
```

**Check connectivity first:**
```bash
ansible all -m ping
```

## What gets installed

| Host | Software |
|------|----------|
| elk-server (3.236.195.167) | Elasticsearch 8.x, Kibana 8.x, Logstash 8.x |
| app-server (44.204.243.77) | nginx, Filebeat 8.x |

## Accessing services after setup

| Service | URL |
|---------|-----|
| Kibana | http://3.236.195.167:5601 |
| Elasticsearch | http://3.236.195.167:9200 |

## Log flow

```
nginx (app) → Filebeat → Logstash :5044 → Elasticsearch → Kibana
```

## Kibana first steps

1. Open http://3.236.195.167:5601
2. Go to **Stack Management → Index Patterns**
3. Create an index pattern: `nginx-*`
4. Go to **Discover** to query your nginx logs

## Notes

- xpack security is disabled for this lab setup — do not expose to the internet in production
- Logstash heap is set to 512m and Elasticsearch to 1g — tuned for t3.large (8GB RAM)
- Filebeat ships nginx access and error logs from `/var/log/nginx/`
