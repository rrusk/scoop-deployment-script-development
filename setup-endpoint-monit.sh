#!/bin/bash
#
#Setup monit to start query-gateway
sudo bash -c "cat > /etc/monit/conf.d/query-gateway" <<'EOF1'
# Monitor gateway
check process query-gateway with pidfile /home/scoopadmin/endpoint/query-gateway/tmp/pids/query-gateway.pid
    start program = "su - scoopadmin -c /home/scoopadmin/bin/start_endpoint.sh"
    stop program = "su - scoopadmin -c /home/scoopadmin/bin/stop_endpoint.sh"
    if 100 restarts within 100 cycles then timeout
EOF1
#
sudo /etc/init.d/monit reload
