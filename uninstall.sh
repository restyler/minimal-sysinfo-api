#!/bin/bash

# Exit on any error
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SERVICE_NAME="n8n-server-monitoring"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo"
  exit 1
fi

echo "Uninstalling ${SERVICE_NAME}..."

# Stop and disable the service
systemctl stop "${SERVICE_NAME}" || true
systemctl disable "${SERVICE_NAME}" || true

# Remove the service file
rm -f "${SERVICE_FILE}"

# Reload systemd to recognize the changes
systemctl daemon-reload

echo "Uninstallation complete!" 