#!/bin/bash

# query instance

for t in {1..5}
do
    tenant_id="00${t}_tenant_abcdefgh"
    echo $tenant_id
    echo "instance"
    # run q 10x
    for r in {1..10}
    do
        time curl -s --max-time 7200 'http://localhost:8777/v2/meters/instance?q.field=project_id&q.field=timestamp&q.field=timestamp&q.op=eq&q.op=ge&q.op=le&q.type=&q.type=&q.type=&q.value='$tenant_id'&q.value=2015-10-12T00%3A00%3A00&q.value=2015-10-15T23%3A59%3A59' 1>/dev/null;
    done
done
