#!/usr/bin/env bash

# detects low disk space

DEVS=$(df \
    --exclude-type=tmpfs \
    --exclude-type=overlay \
    --output=source,pcent | tail -n +2)

IFS='\n'
for dev in "${DEVS[@]}"; do
    disk=$(cut $dev -d\t -f1 | tr -d '%')
    space=$(cut $dev -d\t -f2 | tr -d '%')
    if [ "$space" -gt 50 ]; then
        echo "Disk space almost full on $disk"
    fi
done
