#!/bin/bash

echo_date () {
    echo $(date)
}

run_until () {
    OUTPUT=1;
    while [ "$OUTPUT" != 0 ]; do
        OUTPUT=`sudo rabbitmqctl list_queues|grep 'notifications.info'| awk '{print $2}'`;
        sleep 600s;
    done
}

public_cloud() {
    for d in {1..30}
    do
       if [ ${#d} -ge 2 ]; then date="2015-09-${d}"
          else date="2015-09-0${d}"
       fi
       for t in {1..500}
       do
             tenant_id="00${t}_tenant_abcdefgh"
             if [ $(($t % 2)) -eq 0 ]; then
                  resource_id="nova_resource_t_${t}"
                  python ceilosca-message-simulator.py --url rabbit://stackrabbit:password@localhost/ notify-client -m 160 -s nova -a create -x $tenant_id -r $resource_id -d $date
             else
                  resource_id="cinder_resource_t_${t}"
                  python ceilosca-message-simulator.py --url rabbit://stackrabbit:password@localhost/ notify-client -m 160 -s cinder -a create -x $tenant_id -r $resource_id -d $date
             fi
       done
    done
}


echo_date
public_cloud
run_until
echo_date


