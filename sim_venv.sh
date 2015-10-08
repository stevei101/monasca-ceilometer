#!/bin/bash

cd ~/monasca-ceilometer/tools
/usr/local/bin/virtualenv sim
source sim/bin/activate
pip install oslo.messaging
