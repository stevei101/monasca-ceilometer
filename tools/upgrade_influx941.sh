#!/bin/bash

# upgrade influxdb
wget http://influxdb.s3.amazonaws.com/influxdb_0.9.4.1_amd64.deb
sudo service influxdb stop
sudo dpkg -i --force-confnew influxdb_0.9.4.1_amd64.deb
sudo service influxdb start