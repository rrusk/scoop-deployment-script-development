#!/bin/bash
oscar_passwd="scoop2013"
source /etc/environment
if [ ! -f $CATALINA_HOME/oscar12.properties ]
then
  if [ ! -f ./oscar-env-bc-subs.txt ] 
    then
      echo "ERROR: sedscript is missing!"
      exit
    fi
    sed -f ./oscar-env-bc-subs.txt < $HOME/emr/oscar/src/main/resources/oscar_mcmaster.properties > /tmp/oscar12.properties
    echo "ModuleNames=E2E" >> /tmp/oscar12.properties
    echo "E2E_URL = http://localhost:3001/records/create" >> /tmp/oscar12.properties
    echo "drugref_url=http://localhost:8080/drugref/DrugrefService" >> /tmp/oscar12.properties
    sed --in-place "s/db_password=xxxx/db_password=$oscar_passwd/" /tmp/oscar12.properties
    sudo cp /tmp/oscar12.properties $CATALINA_HOME/
fi
if [ ! -f /etc/default/tomcat6 ]
then
  echo "Tomcat6 is not installed!"
  exit
fi
sudo sed --in-place 's/JAVA_OPTS.*/JAVA_OPTS="-Djava.awt.headless=true -Xmx1024m -Xms1024m -XX:MaxPermSize=512m -server"/' /etc/default/tomcat6
#
# tweak MySQL server
cd $HOME/emr/oscar/database/mysql
java -cp .:$HOME/emr/oscar/local_repo/mysql/mysql-connector-java/3.0.11/mysql-connector-java-3.0.11.jar importCasemgmt $CATALINA_HOME/oscar12.properties
# 
mysql -uroot -p$oscar_passwd -e 'insert into issue (code,description,role,update_date,sortOrderId) select icd9.icd9, icd9.description, "doctor", now(), '0' from icd9;' oscar_12_1
# 
# import and update drugref
cd $HOME/emr
wget http://drugref2.googlecode.com/files/drugref.war
sudo mv drugref.war $CATALINA_BASE/webapps/drugref.war
# 
# Do not indent body of HERE document!
sudo bash -c "cat  >> $CATALINA_HOME/drugref.properties" <<'EOF'
db_user=root
db_password=xxxx
db_url=jdbc:mysql://127.0.0.1:3306/drugref
db_driver=com.mysql.jdbc.Driver
EOF
#
sudo sed --in-place "s/db_password=xxxx/db_password=$oscar_passwd/" $CATALINA_HOME/drugref.properties
# 
# create a new database to hold the drugref.
mysql -uroot -p$oscar_passwd -e "CREATE DATABASE drugref;"
# 
# To apply all the changes to the Tomcat server, we need to restart it
sudo /etc/init.d/tomcat6 restart
