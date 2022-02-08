#!/bin/bash

# A wrapper script for ping

HOST=$1

if [ -z "$HOST" ]
then
  echo "Must provide a host"
  exit 1
fi

ping -c 1 $HOST > /dev/null 2>&1

if [ "$?" -eq "0" ]
then
  echo "$HOST reachable."
else
  echo "$HOST unreachable."
fi

