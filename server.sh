#!/bin/bash

# Use PORT from environment or default to 8090
PORT="${PORT:-8090}"

echo "Starting server on port ${PORT}..."

while true; do
  {
    # Wait for a request (ignore the request content)
    echo -e "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n"
    
    # Get disk usage information
    df_output=$(df -h --output=source,size,used,avail,pcent,target -x tmpfs -x devtmpfs | tail -n +2 | jq -R -s -c 'split("\n")[:-1] | map(split(" ") | map(select(length>0)) | {filesystem:.[0], size:.[1], used:.[2], avail:.[3], use_percent:.[4], mount:.[5]})')
    
    # Get CPU load averages (1, 5, 15 minutes)
    cpu_load=$(cat /proc/loadavg | awk '{print "{\"load_1m\":" $1 ",\"load_5m\":" $2 ",\"load_15m\":" $3 "}"}')
    
    # Get RAM information
    mem_info=$(free -m | grep Mem | awk '{print "{\"total\":" $2 ",\"used\":" $3 ",\"free\":" $4 ",\"shared\":" $5 ",\"cache\":" $6 ",\"available\":" $7 "}"}')
    
    # Combine all information into a single JSON object
    echo "{\"disk\":$df_output,\"cpu\":$cpu_load,\"memory\":$mem_info}"
  } | nc -l -p "${PORT}" -q 1
done