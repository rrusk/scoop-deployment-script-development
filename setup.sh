#!/bin/bash
#
# bring up to date
sudo apt-get --yes update
sudo apt-get --yes upgrade
#
# install basic packages
sudo apt-get --yes install git python-software-properties curl
#
# set up Java 6
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get --yes update
sudo apt-get --yes install oracle-java6-installer
#
# set up mongod
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list
sudo apt-get --yes update
sudo apt-get --yes install mongodb-10gen
#
cd $HOME
# set up ruby and rails
if [ ! -d ".rvm" ]
then
  curl -L https://get.rvm.io | bash -s stable
  echo 'source ~/.profile' >> ~/.bash_profile
  source ~/.bash_profile
  rvm requirements
  rvm install 1.9.3
  rvm use 1.9.3 --default
  rvm rubygems current
  gem install bundler
  gem install rails
fi
#
# intstall libraries needed by scoophealth software
sudo apt-get --yes install libxslt-dev libxml2-dev
#
# other useful packages (Note: screen and script are installed
# in Ubuntu server by default; if they are missing install them)
sudo apt-get --yes install lynx-cur tshark screen script
#
cat >> ~/.bashrc <<'EOF'
#
#http://askubuntu.com/questions/41891/bash-auto-complete-for-environment-variables/
shopt -s direxpand
EOF
#
echo "Use 'sudo vi /etc/resolvconf/resolv.conf.d/head' to add specific nameservers to"
echo "/etc/resolv.conf for DNS lookups.  For instance, add the line"
echo "'nameserver 142.104.6.1' to use UVic's main name service."
