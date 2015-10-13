#!/bin/bash

# all queries

echo_date () {
    echo $(date)
}


private_cloud() {
    ./query_instance.sh &
    ./query_image.sh &
    ./query_volume.sh &
}

echo_date
private_cloud
echo_date
