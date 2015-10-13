#!/bin/bash

# all queries

private_cloud() {
    /bin/bash tquery_instance.sh > tquery_instance.out &
    /bin/bash tquery_image.sh > tquery_image.out &
    /bin/bash tquery_volume.sh tquery_volume.out &
}

private_cloud
