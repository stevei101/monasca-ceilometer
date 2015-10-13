#!/bin/bash

# all query
echo $(date)
./query_instance.sh &
./query_image.sh &
./query_volumee.sh &
echo $(date)