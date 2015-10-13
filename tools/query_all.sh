#!/bin/bash

echo_date () {
    echo $(date)
}

# all query

do_queries () {
    ./query_instance.sh &
    ./query_image.sh &
    ./query_volume.sh &
}


echo_date
do_queries
echo_date