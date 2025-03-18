#!/bin/bash

# Exit on any error
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SERVICE_NAME="minimal-sysinfo-api"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
TEMPLATE_FILE="${SCRIPT_DIR}/${SERVICE_NAME}.service.template"
PORT=8090
USER="root"  # Default to root, but could be changed

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --port=*)
      PORT="${1#*=}"
      shift
      ;;
    --user=*)
      USER="${1#*=}"
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--port=PORT] [--user=USER]"
      exit 1
      ;;
  esac
done

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo"
  exit 1
fi

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check for required dependencies and install them if needed
echo "Checking dependencies..."

# Detect package manager
if command_exists apt-get; then
  PKG_MANAGER="apt-get"
  PKG_INSTALL="apt-get install -y"
  NETCAT_PKG="netcat-openbsd"
elif command_exists yum; then
  PKG_MANAGER="yum"
  PKG_INSTALL="yum install -y"
  NETCAT_PKG="nc"
elif command_exists dnf; then
  PKG_MANAGER="dnf"
  PKG_INSTALL="dnf install -y"
  NETCAT_PKG="nc"
elif command_exists zypper; then
  PKG_MANAGER="zypper"
  PKG_INSTALL="zypper install -y"
  NETCAT_PKG="netcat"
else
  echo "Warning: Could not detect package manager. Please ensure 'jq' and 'netcat' are installed manually."
  PKG_MANAGER=""
fi

# Install jq if not present
if ! command_exists jq; then
  echo "jq not found. Installing..."
  if [ -n "$PKG_MANAGER" ]; then
    $PKG_INSTALL jq
  else
    echo "Error: jq is required but could not be installed automatically."
    echo "Please install jq manually and run this script again."
    exit 1
  fi
fi

# Install netcat if not present
if ! (command_exists nc || command_exists netcat); then
  echo "netcat not found. Installing..."
  if [ -n "$PKG_MANAGER" ]; then
    $PKG_INSTALL $NETCAT_PKG
  else
    echo "Error: netcat is required but could not be installed automatically."
    echo "Please install netcat manually and run this script again."
    exit 1
  fi
fi

echo "All dependencies are satisfied."

# Check if template exists
if [ ! -f "${TEMPLATE_FILE}" ]; then
  echo "Error: Service template file not found at ${TEMPLATE_FILE}"
  exit 1
fi

# Make sure server.sh is executable
chmod +x "${SCRIPT_DIR}/server.sh"

# Create systemd service file from template with variable substitution
cat "${TEMPLATE_FILE}" | \
  sed "s|__SCRIPT_DIR__|${SCRIPT_DIR}|g" | \
  sed "s|__SERVICE_NAME__|${SERVICE_NAME}|g" | \
  sed "s|__USER__|${USER}|g" | \
  sed "s|__PORT__|${PORT}|g" \
  > "${SERVICE_FILE}"

# Reload systemd to recognize the new service
systemctl daemon-reload

# Enable and start the service
systemctl enable "${SERVICE_NAME}"

# Restart the service (will start it if not running)
systemctl restart "${SERVICE_NAME}"

echo "Installation complete!"
echo "Service status:"
systemctl status "${SERVICE_NAME}"
echo ""
echo "You can check the service with: systemctl status ${SERVICE_NAME}"
echo "You can view logs with: journalctl -u ${SERVICE_NAME}"
echo "The monitoring server is running on port ${PORT}"
echo "To uninstall, run: sudo ${SCRIPT_DIR}/uninstall.sh" 