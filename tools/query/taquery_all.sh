#!/bin/bash

# all queries

echo_date () {
    echo $(date)
}

run_until () {
    while [ kill -0 $pid0 ||  kill -0 $pid1 ||  kill -0 $pid2 ]; do
        sleep 1s
    done
}

private_cloud() {
    /bin/bash tquery_instance.sh &
    pid0=$!
    # If this script is killed, kill query.
    trap "kill $pid0" EXIT
    /bin/bash tquery_instance.sh &
    pid1=$!
    # If this script is killed, kill query.
    trap "kill $pid1" EXIT
    /bin/bash tquery_instance.sh &
    pid2=$!
    # If this script is killed, kill query.
    trap "kill $pid2" EXIT
}

echo_date
private_cloud
run_until
echo_date
trap - EXIT