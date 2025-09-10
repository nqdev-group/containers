#!/bin/bash
container_name=$1

docker-compose up -d --build --force-recreate --remove-orphans --timestamps
