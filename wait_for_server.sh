#!/usr/bin/env bash

# wait for a successful IPv4 TCP connection

set -euo pipefail

usage () {
	echo "Usage: $0 host port [timeout]"
}

if [ $# -lt "2" ]; then
	usage
	exit 1
fi

SERVER="$1"
PORT="$2"
CONNECT_TIMEOUT="${3-2}"

while ! nc -4zw "$CONNECT_TIMEOUT" "$SERVER" "$PORT" >/dev/null 2>&1; do
	echo "Waiting for ${SERVER}:${PORT}..."
	sleep 5
done

echo "Connected to ${SERVER}:${PORT}!"
