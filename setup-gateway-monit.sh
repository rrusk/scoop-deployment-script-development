#!/bin/bash
##
## Create bin/start-endpoint.sh
##
if [ ! -d $HOME/bin ]
then
  mkdir $HOME/bin
fi
#
cat > $HOME/bin/start-endpoint.sh << 'EOF1'
#!/bin/sh
#
#echo "Starting relay service on port 3000"
#$HOME/endpoint/query-gateway/util/relay-service.rb >> $HOME/logs/rs.log 2>&1 &
#
echo "Starting Query Gateway on port 3001"
cd $HOME/endpoint/query-gateway
if [ -f $HOME/endpoint/query-gateway/tmp/pids/delayed_job.pid ];
then
  bundle exec $HOME/endpoint/query-gateway/script/delayed_job stop
  rm $HOME/endpoint/query-gateway/tmp/pids/delayed_job.pid
fi
#
bundle exec $HOME/endpoint/query-gateway/script/delayed_job start
#
# If gateway isn't running, start it.
if [ -f $HOME/endpoint/query-gateway/tmp/pids/query-gateway.pid ];
then
  bundle exec rails server -p 3001 -d
  /bin/ps -ef | grep "rails server -p 3001" | grep -v grep | awk '{print $2}' > tmp/pids/query-gateway.pid
fi
#
#cd $HOME/logs
#tail -f rs.log
EOF1
#
##
## Create bin/stop-endpoint.sh
##
cat > $HOME/bin/stop-endpoint.sh << 'EOF2'
#!/bin/sh
cd $HOME/endpoint/query-gateway
if [ -f $HOME/endpoint/query-gateway/tmp/pids/delayed_job.pid ];
then
  bundle exec $HOME/endpoint/query-gateway/script/delayed_job stop
  # pid file should be gone but recheck
  if [ -f $HOME/endpoint/query-gateway/tmp/pids/delayed_job.pid ];
  then
    rm $HOME/endpoint/query-gateway/tmp/pids/delayed_job.pid
  fi
fi
#
# If gateway is running, stop it.
if [ -f $HOME/endpoint/query-gateway/tmp/pids/query-gateway.pid ];
then
  kill `cat $HOME/endpoint/query-gateway/tmp/pids/query-gateway.pid`
  rm $HOME/endpoint/query-gateway/tmp/pids/query-gateway.pid
fi
EOF2
#
chmod a+x $HOME/bin/*
#
##
## Configure monit to control the query-gateway
##
#!/bin/bash
#
#Setup monit to start query-gateway
sudo bash -c "cat > /etc/monit/conf.d/query-gateway" <<'EOF1'
# Monitor gateway
check process query-gateway with pidfile /home/scoopadmin/endpoint/query-gateway/tmp/pids/query-gateway.pid
    start program = "/home/scoopadmin/bin/start_endpoint.sh" as uid scoopadmin and with gid scoopadmin
    stop program = "/home/scoopadmin/bin/stop_endpoint.sh" as uid scoopadmin and with gid scoopadmin
    if 100 restarts within 100 cycles then timeout
EOF1
#
sudo /etc/init.d/monit reload
