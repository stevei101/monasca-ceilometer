#!/bin/bash

# all queries

echo_date () {
    echo $(date)
}

private_cloud() {
    /bin/bash tquery_instance.sh > tquery_instance.out &
    /bin/bash tquery_image.sh > tquery_image.out &
    /bin/bash tquery_volume.sh tquery_volume.out &
}

echo_date
private_cloud
echo_date
