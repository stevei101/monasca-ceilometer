#!/bin/sh

# all queries
echo $(date)
./query_instance.sh &
./query_image.sh &
./query_volume.sh &
echo $(date)