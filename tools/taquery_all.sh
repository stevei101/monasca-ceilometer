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
    /bin/bash tquery_instance.sh &
    pid1=$!
    /bin/bash tquery_instance.sh &
    pid2=$!
}

echo_date
private_cloud
run_until
echo_date
