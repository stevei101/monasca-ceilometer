#!/bin/bash

# all queries

echo_date () {
    echo $(date)
}

run_until () {
    while kill -0 $pid 2> /dev/null; do
        sleep 1s
    done
}

private_cloud() {
    /bin/bash tquery_instance.sh &
    pid=$!

}

echo_date
private_cloud
run_until
echo_date
