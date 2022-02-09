#! /bin/bash

# This script installs Apache on Ubuntu

if [ $(id -u) != 0 ]
then
  echo "This script requires root privileges"
  exit 1
fi

apt update


