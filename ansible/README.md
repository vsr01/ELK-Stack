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

## Workflow after recreating EC2 instances

IPs change every time instances are recreated. Run this first to sync them:
```bash
./scripts/update-inventory.sh
```

Then run the playbooks:
```bash
cd ansible
ansible all -m ping          # verify SSH connectivity
ansible-playbook site.yml    # full setup
```

## Running individual playbooks

```bash
ansible-playbook elk.yml     # ELK instance only
ansible-playbook app.yml     # app instance only
```

## What gets installed

| Host | Software |
|------|----------|
| elk-server | Elasticsearch 8.x, Kibana 8.x, Logstash 8.x |
| app-server | nginx, Filebeat 8.x |

## Accessing services after setup

| Service | URL |
|---------|-----|
| Kibana  | http://\<elk_public_ip\>:5601 |
| Elasticsearch | http://\<elk_public_ip\>:9200 |

## Log flow

```
nginx (app) → Filebeat → Logstash :5044 → Elasticsearch → Kibana
```

## Kibana setup

1. Open `http://<elk_public_ip>:5601`
2. Go to **Stack Management → Data Views**
3. Click **Create data view**
4. Set index pattern to `nginx-*` and timestamp field to `@timestamp`
5. Save, then go to **Discover** to explore logs

### Useful fields in Discover

| Field | Description |
|-------|-------------|
| `@timestamp` | When the request hit nginx |
| `source.address` | Client IP |
| `http.request.method` | GET, POST, etc. |
| `url.original` | Requested path |
| `http.response.status_code` | 200, 404, 500, etc. |
| `http.response.body.bytes` | Response size |
| `user_agent.original` | Browser / client |

Pin fields as columns in Discover by clicking `+` next to them in the left sidebar.

## Troubleshooting

**Elasticsearch fails to start (exit code 78 — cannot create logs dir)**
The installer sets `/usr/share/elasticsearch` owned by root. The playbook
pre-creates `data`, `logs`, and `plugins` subdirs with `elasticsearch` ownership
before starting the service.

**Elasticsearch fails to start (xpack SSL keystore conflict)**
The apt package seeds the keystore with SSL entries that conflict when security
is disabled. The playbook removes them automatically before starting the service.

**Logstash pipeline error — geoip requires target**
In ECS v8 compatibility mode the geoip filter requires an explicit `target` field.
The pipeline config sets `target => "geoip"` to satisfy this.

**Logstash jvm.options.d does not exist**
The apt package does not create this directory. The playbook creates it before
writing the heap options file.

**Filebeat cannot connect to Logstash (connection refused)**
Check that Logstash is running on the ELK instance:
```bash
ssh ubuntu@<elk_ip> sudo systemctl status logstash
```
Check Filebeat can reach Logstash:
```bash
ssh ubuntu@<app_ip> sudo filebeat test output
```

**`nginx-*` index pattern not found in Kibana**
No data has arrived yet. Generate some traffic first:
```bash
curl http://<app_public_ip>
```
Then check indices exist in Elasticsearch:
```bash
curl http://<elk_public_ip>:9200/_cat/indices?v
```

**`_geoip_lookup_failure` tag on log entries**
Logstash downloads the MaxMind GeoIP database in the background after startup.
This tag appears until the download completes (usually a few minutes).

## Notes

- xpack security is disabled — do not expose these instances publicly in production
- Elasticsearch heap: 1g, Logstash heap: 512m — tuned for t3.large (8GB RAM)
- The Kibana encryption key is generated once and persisted at `/etc/kibana/encryption_key`
  so saved objects survive playbook re-runs
