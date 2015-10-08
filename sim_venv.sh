#!/bin/bash

cd ~/monasca-ceilometer/tools
/usr/local/bin/virtualenv sim
source sim/bin/activate
/usr/local/bin/pip install oslo.messaging
