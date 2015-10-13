#!/bin/sh

# all queries
./tquery_instance.sh > tquery_instance.out &
./tquery_image.sh > tquery_image.out &
./tquery_volume.sh > tquery_volume.out &
