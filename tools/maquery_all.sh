#!/bin/bash

# all queries

echo_date () {
    echo $(date)
}

private_cloud() {
    /bin/bash tquery_instance.sh > tquery_instance.sh &
    /bin/bash tquery_image.sh > tquery_image.sh &
    /bin/bash tquery_volume.sh tquery_volume.sh &
}

echo_date
private_cloud
echo_date
