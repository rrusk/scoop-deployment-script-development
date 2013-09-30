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
#
