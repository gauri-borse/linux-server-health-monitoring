
#!/bin/bash

# Linux Server Health Monitoring System

PROJECT_DIR="$HOME/linux-server-monitor"
LOG_FILE="$PROJECT_DIR/logs/server-health.log"

# Create log directory if missing
mkdir -p "$PROJECT_DIR/logs"

# Collect system information
HOSTNAME=$(hostname)
CURRENT_TIME=$(date '+%Y-%m-%d %H:%M:%S')
LOAD=$(awk '{print $1}' /proc/loadavg)

# Calculate memory usage percentage
MEMORY=$(free | awk '/Mem:/ {
    if ($2 > 0)
        printf "%.0f", ($3 / $2) * 100
    else
        print 0
}')

# Calculate root filesystem disk usage
DISK=$(df -P / | awk 'NR==2 {
    gsub("%","",$5)
    print $5
}')

# Record the monitoring report
{
    echo "======================================"
    echo "Linux Server Health Report"
    echo "Time: $CURRENT_TIME"
    echo "Hostname: $HOSTNAME"
    echo "Load Average (1 min): $LOAD"
    echo "Memory Usage: ${MEMORY}%"
    echo "Root Disk Usage: ${DISK}%"

    if [ "$MEMORY" -ge 80 ]; then
        echo "WARNING: High memory usage!"
    fi

    if [ "$DISK" -ge 80 ]; then
        echo "WARNING: High disk usage!"
    fi

    echo "Top CPU-consuming processes:"
    ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6

    echo "Monitoring completed."
    echo
} | tee -a "$LOG_FILE"
