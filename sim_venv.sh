#!/bin/bash

cd ~/monasca-ceilometer/tools
/usr/bin/local/virtualenv sim
source sim/bin/activate
/usr/bin/pip install oslo.messaging
