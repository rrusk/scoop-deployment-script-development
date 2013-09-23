#!/bin/sh
#
#echo "Starting relay service on port 3000"
#$HOME/util/relay-service.rb >> $HOME/logs/rs.log 2>&1 &
#
echo "Starting Query Gateway on port 3001"
cd $HOME/endpoint/query-gateway
if [ -f $HOME/endpoint/query-gateway/tmp/pids/delayed_job.pid ];
then
  bundle exec $HOME/endpoint/query-gateway/script/delayed_job stop
  rm $HOME/query-gateway/endpoint/tmp/pids/delayed_job.pid
fi
bundle exec $HOME/endpoint/query-gateway/script/delayed_job start
bundle exec rails server -p 3001 &
#cd $HOME/logs
#tail -f rs.log
