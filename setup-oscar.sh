#!/bin/bash
if [ -z "$1" ]
then
  echo "Usage: setup-oscar.sh oscar_password"
  exit
fi
oscar_passwd=$1
echo "Create Oscar database with password $oscar_passwd"
#

cd $HOME
# install MySQL
if [ ! -d /var/lib/mysql ]
then
  sudo apt-get --yes install mysql-server libmysql-java
fi
# install Tomcat and Maven
if [ ! -d /var/lib/tomcat6 ]
then
  sudo apt-get --yes install tomcat6 maven git-core
  #
  # set up Tomcat's deployment environment
  # Do not indent body of HERE document!
  sudo bash -c "cat  >> /etc/environment" <<'EOF'
JAVA_HOME="/usr/lib/jvm/java-6-oracle"
CATALINA_HOME="/usr/share/tomcat6"
CATALINA_BASE="/var/lib/tomcat6"
ANT_HOME="/usr/share/ant"
EOF
#
fi
#
source /etc/environment
if [ -z "$CATALINA_BASE" ]
then
  echo "Failed to configure CATALINA_HOME in /etc/environment.  Exiting..."
  exit
fi
sudo update-alternatives --config java
sudo update-alternatives --config javac
sudo update-alternatives --config javaws
#
# install Oscar
if [ ! -d $HOME/emr ]
then
  mkdir $HOME/emr
fi
cd $HOME/emr
#
# retrieve Oscar from github
if [ ! -d ./oscar ]
then
  git clone git://github.com/scoophealth/oscar.git
fi
if [ ! -d ./oscar ]
then
  exit
fi
cd ./oscar
git checkout scoop-deploy
git pull
#
# build Oscar from source
source /etc/environment
export CATALINA_HOME
mvn -Dmaven.test.skip=true verify
sudo cp ./target/*.war $CATALINA_BASE/webapps/oscar12.war
#
# build oscar_documents from source
cd $HOME/emr
if [ ! -d ./oscar_documents ]
then
  git clone git://oscarmcmaster.git.sourceforge.net/gitroot/oscarmcmaster/oscar_documents
else
  cd ./oscar_documents
  git pull
fi
cd $HOME/emr
if [ ! -d ./oscar_documents ]
then
  exit
fi
cd ./oscar_documents
mvn -Dmaven.test.skip=true clean package
sudo cp ./target/*.war $CATALINA_BASE/webapps/OscarDocument.war
#
# create oscar database
cd $HOME/emr/oscar/database/mysql
export PASSWORD=$oscar_passwd
./createdatabase_bc.sh root $PASSWORD oscar_12_1
