#!/usr/bin/env bash

# print the system users with description

cut -d: -f1,5 /etc/passwd
