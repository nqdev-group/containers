#!/bin/bash
container_name='nginx-server'

if [ "$1" = "vm74" ]; then
    container_name='nginx-server-vm74'
elif [ "$1" = "vm60" ]; then
    container_name='nginx-server-vm60'
else
    echo 0
fi

echo $container_name
docker exec $container_name nginx -s reload

exit 0
