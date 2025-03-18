#!/bin/bash

# Use PORT from environment or default to 8090
PORT="${PORT:-8090}"

echo "Starting server on port ${PORT}..."

while true; do
  {
    # Wait for a request (ignore the request content)
    echo -e "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n"
    
    # Get disk usage information in bytes instead of human-readable format
    df_output=$(df --output=source,size,used,avail,pcent,target -x tmpfs -x devtmpfs | tail -n +2 | jq -R -s -c 'split("\n")[:-1] | map(split(" ") | map(select(length>0)) | {
      filesystem: .[0],
      size_kb: (.[1] | tonumber),
      used_kb: (.[2] | tonumber),
      avail_kb: (.[3] | tonumber),
      use_percent: (.[4] | gsub("%"; "") | tonumber),
      mount: .[5]
    })')
    
    # Get CPU load averages (1, 5, 15 minutes)
    cpu_load=$(cat /proc/loadavg | awk '{print "{\"load_1m\":" $1 ",\"load_5m\":" $2 ",\"load_15m\":" $3 "}"}')
    
    # Get RAM information in KB
    mem_info=$(free | grep Mem | awk '{print "{\"total_kb\":" $2 ",\"used_kb\":" $3 ",\"free_kb\":" $4 ",\"shared_kb\":" $5 ",\"cache_kb\":" $6 ",\"available_kb\":" $7 "}"}')
    
    # Get CPU information
    cpu_info=$(cat /proc/stat | grep '^cpu ' | awk '{print "{\"user\":" $2 ",\"nice\":" $3 ",\"system\":" $4 ",\"idle\":" $5 ",\"iowait\":" $6 ",\"irq\":" $7 ",\"softirq\":" $8 "}"}')
    
    # Get uptime in seconds
    uptime_info=$(cat /proc/uptime | awk '{print "{\"uptime_seconds\":" $1 ",\"idle_seconds\":" $2 "}"}')
    
    # Combine all information into a single JSON object
    echo "{\"disk\":$df_output,\"cpu\":$cpu_load,\"cpu_stats\":$cpu_info,\"memory\":$mem_info,\"uptime\":$uptime_info}"
  } | nc -l -p "${PORT}" -q 1
done