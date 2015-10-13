#!/bin/bash

# all queries

private_cloud() {
    nohup /bin/bash tquery_instance.sh > tquery_instance.out 2>&1 &
    nohup /bin/bash tquery_image.sh > tquery_image.out 2>&1 &
    nohup /bin/bash tquery_volume.sh > tquery_volume.out 2>&1 &
}

private_cloud
