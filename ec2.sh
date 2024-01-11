#!/bin/bash
NAMES=("mangodb" "cart" "mysql" "shipping" "user" "payment" "rabbitmq" "redis" "catalogue" "web")

for i in "${NAMES[@]}"
do
    eccho "NAMES : $i"
done