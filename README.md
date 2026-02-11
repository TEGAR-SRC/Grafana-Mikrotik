# Grafana Mikrotik Monitoring

![logo](https://repository-images.githubusercontent.com/366494855/c62052b8-17c2-47f2-a3ae-0e397a3ef074)

![visitors](https://visitor-badge.laobi.icu/badge?page_id=TEGAR-SRC.Grafana-Mikrotik)
![example branch parameter](https://github.com/TEGAR-SRC/Grafana-Mikrotik/actions/workflows/action.yml/badge.svg?branch=main)
![mikrotikOS](https://img.shields.io/badge/Mikrotik_ROS-v7.4-blue)
![Grafana](https://img.shields.io/badge/Grafana-v9.0.5-orange?logo=grafana)
![Prometheus](https://img.shields.io/badge/Prometheus-v2.37.0-red?logo=prometheus)
![snmp_exporter](https://img.shields.io/badge/snmp__exporter-v0.20.0-red?logo=prometheus)

---

## 🚀 Quick Install (One Command)

### Auto Installer (Recommended)
```bash
curl -fsSL https://raw.githubusercontent.com/TEGAR-SRC/Grafana-Mikrotik/main/install.sh | bash
```

### Download & Run Manual
```bash
# Linux/macOS
wget https://raw.githubusercontent.com/TEGAR-SRC/Grafana-Mikrotik/main/install.sh
chmod +x install.sh
./install.sh
```

```powershell
# Windows PowerShell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TEGAR-SRC/Grafana-Mikrotik/main/install.sh" -OutFile "install.sh"
bash install.sh
```

### Direct Download
- **Repository:** https://github.com/TEGAR-SRC/Grafana-Mikrotik.git
- **ZIP Download:** https://github.com/TEGAR-SRC/Grafana-Mikrotik/archive/refs/heads/main.zip

## 🐳 Deploy with docker-compose

### Deploy with bash script

```console
git clone https://github.com/TEGAR-SRC/Grafana-Mikrotik.git
cd ./Grafana-Mikrotik
bash ./run.sh --config
```

```console
  You can also pass some arguments to script to set some these options:

    --config: change the user and password to grafana and specify the mikrotik IP address

    --stop: stop docker containers

    --help
```

For example:

```console
    bash run.sh --config
```

[![asciicast](https://asciinema.org/a/nOhuc7LvI6bRWbg7dcvqFQ4Kc.png)](https://asciinema.org/a/nOhuc7LvI6bRWbg7dcvqFQ4Kc)

### deploy with docker-compose manual

1. Change targets IP in file `prometheus/prometheus.yml` (already configured with multiple IPs)

2. Run

```console
docker-compose up -d
```

3. Open [localhost:3000](http://localhost:3000)

* Grafana login: `xxken`
* Password: `xxkenxyz`

## 📊 Current Configuration

### Mikrotik IPs Being Monitored:
- 10.10.10.1
- 172.16.1.1
- 103.144.46.1
- 103.144.46.18
- 103.144.46.219

### SNMP Community String
- Community: `xxkenxyz`

### To Add/Remove IPs
Edit `prometheus/prometheus.yml`:
```yaml
- job_name: Mikrotik
  static_configs:
    - targets:
      - YOUR_IP_HERE
```

Edit `.prometheus` file:
```bash
MIKROTIK_IP=IP1,IP2,IP3
```

### To Change SNMP Community
Edit `snmp/snmp.yml`:
```yaml
auths:
    public_v2:
        community: YOUR_COMMUNITY_STRING
```

### To Change Grafana Credentials
Edit `.grafana` file:
```bash
GF_SECURITY_ADMIN_USER=YOUR_USERNAME
GF_SECURITY_ADMIN_PASSWORD=YOUR_PASSWORD
```

## 🔧 Commands

- Stop services: `docker-compose down`
- Restart services: `docker-compose restart`
- View logs: `docker-compose logs -f`
- Update config: `docker-compose up -d --force-recreate`

## 📋 Requirements

- Docker
- Docker Compose
- Mikrotik devices with SNMP enabled

## 🔒 Mikrotik SNMP Setup

On each Mikrotik device:
```
/snmp
set enabled=yes
/community
add name=xxkenxyz addresses=YOUR_GRAFANA_IP
```

---

## Manual deploy

1.add into prometheus.yml

```yml
  - job_name: Mikrotik
    static_configs:
      - targets:
        - 192.168.88.1  # SNMP device IP.
    metrics_path: /snmp
    params:
      module: [mikrotik]
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: localhost:9116  # The SNMP exporter's real hostname:port.
```

2.Configure Prometheus and run /snmp/snmp_exporter

3.Add dashboard <https://grafana.com/grafana/dashboards/14420>

---

### Docker snmp_exporter (deprecated)

[![Docker Pulls](https://img.shields.io/docker/pulls/mashinkopochinko/snmp_exporter_mikrotik?logo=docker)](https://hub.docker.com/repository/docker/mashinkopochinko/snmp_exporter_mikrotik)

> amd64-linux container

```console
sudo docker run -d -p 9116:9116 mashinkopochinko/snmp_exporter_mikrotik:latest
```

---
![img1](/readme/screen.png)
