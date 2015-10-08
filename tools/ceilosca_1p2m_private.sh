#!/bin/bash

services=( nova nova nova nova cinder cinder cinder cinder glance glance )

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

private_cloud() {
    for d in {1..30}
    do 
       if [ ${#d} -ge 2 ]; then date="2015-09-${d}"
          else date="2015-09-0${d}"
       fi
       for t in {1..5}
       do
              tenant_id="00${t}_tenant_abcdefgh"
              for s in "${services[@]}"
              do
                   #echo $date
                   #echo $tenant_id
                   resource_id="${s}_resource_t_${t}"
                   #echo $resource_id
                   python ceilosca-message-simulator.py --url rabbit://stackrabbit:password@localhost/ notify-client -m 800 -s $s -a create -x $tenant_id -r $resource_id -d $date
              done
       done
    done
}


echo_date
private_cloud
run_until
echo_date
