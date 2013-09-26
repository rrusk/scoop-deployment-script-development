#!/bin/bash
#
echo
echo "Creating unprivileged user account <autossh> for reverse ssh tunnelling"
echo "The root user public rsa key for each endpoint must be added to "
echo "/home/autossh/.ssh/authorized_keys on the hub."
sudo adduser --disabled-password autossh
sudo mkdir /home/autossh/.ssh
sudo touch /home/autossh/.ssh/authorized_keys
#sudo vi /home/autossh/.ssh/authorized_keys
sudo chmod -R go-rwx /home/autossh/.ssh
sudo chown -R autossh:autossh /home/autossh/.ssh
#
sudo mkdir -p /usr/local/reverse_ssh/bin
sudo bash -c "cat  > /usr/local/reverse_ssh/bin/start_tunnel.sh" <<'EOF'
#!/bin/bash
REMOTE_ACCESS_PORT=30309
LOCAL_PORT_TO_FORWARD=22
export AUTOSSH_PIDFILE=/usr/local/reverse_ssh/autossh.pid
/usr/bin/autossh -M0 -p22 -N -R ${REMOTE_ACCESS_PORT}:localhost:${LOCAL_PORT_TO_FORWARD} autossh@scoophub.cs.uvic.ca -o ServerAliveInterval=15 -o ServerAliveCountMax=3 -o Protocol=2 -o ExitOnForwardFailure=yes &
#
EOF
#
#
sudo bash -c "cat  > /usr/local/reverse_ssh/bin/stop_tunnel.sh" <<'EOF'
#!/bin/sh
test -e /usr/local/reverse_ssh/autossh.pid && kill `cat /usr/local/reverse_ssh/autossh.pid`
EOF
#
sudo chown -R root:root /usr/local/reverse_ssh
sudo chmod 700 /usr/local/reverse_ssh/bin/*.sh
#
#Setup monit to restart autossh
sudo bash -c "cat > /etc/monit/conf.d/autossh" <<'EOF'
# Monitor autossh
check process autossh with pidfile /usr/local/reverse_ssh/autossh.pid
    start program = "/usr/local/reverse_ssh/bin/start_tunnel.sh"
    stop program = "/usr/local/reverse_ssh/bin/stop_tunnel.sh"
    if 100 restarts within 100 cycles then timeout
EOF
#
sudo /etc/init.d/monit reload
#
echo
echo "Access endpoint from account on hub as follows:"
echo "ssh -t -l scoopadmin localhost -p 30309 screen -m"
echo "Note that the password request is for the scoopadmin account"
echo "on the endpoint which can be different from the password of"
echo "the scoopadmin acount on the hub."
