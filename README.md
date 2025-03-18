# Minimalistic Server Monitoring via API

A minimalistic approach to server monitoring, initially built for n8n to poll data from multiple servers.
I have built this because I think maintaining Prometheus and Nagios is a bit of an overkill for my use case [(and apparently I am not the only one)](https://community.n8n.io/t/suggestion-to-monitor-server-cpu-memory-disks/88991).

## Overview

This lightweight monitoring solution provides essential server metrics via a simple HTTP endpoint. It's designed to be:

- **Minimal**: No complex dependencies, just basic Linux tools: `nc` for web server and `jq` for JSON output.
- **Efficient**: Low resource usage.    
- **Easy to install**: Simple installation via systemd. Systemd file is generated from a template because I hate to create these manually.
- **n8n-friendly**: Returns JSON data that's easy to consume in n8n workflows.

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

