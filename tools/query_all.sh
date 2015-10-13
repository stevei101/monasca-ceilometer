#!/bin/bash

echo_date () {
    echo $(date)
}

# all query
echo_date
./query_instance.sh &
./query_image.sh &
./query_volume.sh &
echo_date