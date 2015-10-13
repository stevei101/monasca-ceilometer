#!/bin/bash

# all queries

echo_date () {
    echo $(date)
}

run_until () {
    while [ kill -0 $pid0 2> /dev/null ||  kill -0 $pid1 2> /dev/null ||  kill -0 $pid2 2> /dev/null]; do
        sleep 1s
    done
}

private_cloud() {
    /bin/bash tquery_instance.sh > tquery_instance.out &
    pid0=$!
    /bin/bash tquery_image.sh > tquery_image.out &
    pid1=$!
    /bin/bash tquery_volume.sh > tquery_volume.out &
    pid2=$!
}

echo_date
private_cloud
run_until
echo_date
