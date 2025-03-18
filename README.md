# Minimalistic Server Monitoring via API

A minimalistic approach to server monitoring, initially built for n8n to poll data from multiple servers.
I have built this because I think maintaining Prometheus and Nagios is a bit of an overkill for my use case [(and apparently I am not the only one)](https://community.n8n.io/t/suggestion-to-monitor-server-cpu-memory-disks/88991).

This was only tested on Ubuntu 20+.

## Overview

This lightweight monitoring solution provides essential server metrics via a simple HTTP endpoint. It's designed to be:

- **Minimal**: No complex dependencies, just basic Linux tools: `nc` for web server and `jq` for JSON output.
- **Efficient**: Low resource usage.    
- **Easy to install**: Simple installation via systemd. Systemd file is generated from a template because I hate to create these manually.
- **n8n-friendly**: Returns JSON data that's easy to consume in n8n workflows.

## Sample Output

```json
{
    "disk": [
        {
            "filesystem": "/dev/sda1",
            "size_kb": 78425224,
            "used_kb": 41082340,
            "avail_kb": 34098144,
            "use_percent": 55,
            "mount": "/"
        },
        {
            "filesystem": "overlay",
            "size_kb": 78425224,
            "used_kb": 41082340,
            "avail_kb": 34098144,
            "use_percent": 55,
            "mount": "/var/lib/docker/overlay2/93f5e264d463dff34863a4fe0a86b4f61f7e99c8eb54a15441214c8501d68a77/merged"
        }
    ],
    "cpu": {
        "load_1m": 0.86,
        "load_5m": 0.92,
        "load_15m": 0.92
    },
    "cpu_stats": {
        "user": 743391526,
        "nice": 83116740,
        "system": 1249687046,
        "idle": 8284285636,
        "iowait": 9180962,
        "irq": 0,
        "softirq": 117703522
    },
    "memory": {
        "total_kb": 3907352,
        "used_kb": 2238756,
        "free_kb": 381308,
        "shared_kb": 4092,
        "cache_kb": 1287288,
        "available_kb": 1362844
    },
    "uptime": {
        "uptime_seconds": 35178802.07,
        "idle_seconds": 82842856.36
    }
}
```


## Metrics Provided

- **Disk Usage**: Space usage for all mounted filesystems
- **CPU Load**: 1, 5, and 15-minute load averages
- **Memory Usage**: RAM statistics including total, used, free, and available memory

## Installation

### Quick Install (Default Settings)


1. **Clone the repository or download the scripts:**

   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Run the installation script:**
8090 is the default port. You can change it by passing a different port to the script.
   ```bash
   ./install.sh --port=8090
   ```

3. **Check the service status:**

   ```bash
   systemctl status n8n-server-monitoring
   ```

4. **Access the monitoring endpoint:**

   ```bash
   curl http://localhost:8090/
   ```

5. Restart the service:

   ```bash
   sudo systemctl restart n8n-server-monitoring
   ```

6. Uninstall the service:

   ```bash
   sudo ./uninstall.sh
   ```

