#!/bin/bash -xe

#Change to Home directory
cd $HOME

#Essentials
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install git
wget https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py
sudo apt-get -y install python-dev
sudo pip install numpy
sudo pip install python-monascaclient

#Handle if http_proxy is set
if [ $http_proxy ]; then
  git config --global url.https://git.openstack.org/.insteadOf git://git.openstack.org/
  sudo git config --global url.https://git.openstack.org/.insteadOf git://git.openstack.org/
  protocol=`echo $http_proxy | awk -F: '{print $1}'`
  host=`echo $http_proxy | awk -F/ '{print $3}' | awk -F: '{print $1}'`
  port=`echo $http_proxy | awk -F/ '{print $3}' | awk -F: '{print $2}'`
  echo "<settings>
          <proxies>
              <proxy>
                  <id>$host</id>
                  <active>true</active>
                  <protocol>$protocol</protocol>
                  <host>$host</host>
                  <port>$port</port>
              </proxy>
          </proxies>
         </settings>" > ./maven_proxy_settings.xml
  mkdir -p ~/.m2
  cp ./maven_proxy_settings.xml ~/.m2/settings.xml
  sudo mkdir -p /root/.m2
  sudo cp ./maven_proxy_settings.xml /root/.m2/settings.xml
fi

#Clone devstack and switch to liberty
git clone https://git.openstack.org/openstack-dev/devstack | true
cd devstack
git checkout stable/liberty

#Add hard coded IP to the default interface
##NOTE: Change the interface if your system is different net_if
export SERVICE_HOST=192.168.10.6
export HOST_IP_IFACE=eth0
sudo ip addr add $SERVICE_HOST/24 dev $HOST_IP_IFACE || true

#local.conf for devstack
echo '[[local|localrc]]
SERVICE_HOST=$SERVICE_HOST
HOST_IP=$SERVICE_HOST
HOST_IP_IFACE=$HOST_IP_IFACE
MYSQL_HOST=$SERVICE_HOST
MYSQL_PASSWORD=secretmysql
DATABASE_PASSWORD=secretdatabase
RABBIT_PASSWORD=secretrabbit
ADMIN_PASSWORD=secretadmin
SERVICE_PASSWORD=secretservice
SERVICE_TOKEN=111222333444
LOGFILE=$DEST/logs/stack.sh.log
LOGDIR=$DEST/logs
LOG_COLOR=False
#disable_all_services
disable_service horizon
disable_service ceilometer-alarm-notifier ceilometer-alarm-evaluator
disable_service ceilometer-collector
enable_service rabbit mysql key tempest
# The following two variables allow switching between Java and Python for the implementations
# of the Monasca API and the Monasca Persister. If these variables are not set, then the
# default is to install the Java implementations of both the Monasca API and the Monasca Persister.
# Uncomment one of the following two lines to choose Java or Python for the Monasca API.
#MONASCA_API_IMPLEMENTATION_LANG=${MONASCA_API_IMPLEMENTATION_LANG:-java}
MONASCA_API_IMPLEMENTATION_LANG=${MONASCA_API_IMPLEMENTATION_LANG:-python}
# Uncomment one of the following two lines to choose Java or Python for the Monasca Pesister.
#MONASCA_PERSISTER_IMPLEMENTATION_LANG=${MONASCA_PERSISTER_IMPLEMENTATION_LANG:-java}
MONASCA_PERSISTER_IMPLEMENTATION_LANG=${MONASCA_PERSISTER_IMPLEMENTATION_LANG:-python}
# This line will enable all of Monasca.
enable_plugin monasca-api https://git.openstack.org/openstack/monasca-api
enable_plugin ceilometer https://git.openstack.org/openstack/ceilometer stable/liberty
enable_plugin ceilosca https://github.com/srsakhamuri/monasca-ceilometer
' > local.conf

#Run the stack.sh
./unstack.sh | true
./stack.sh
