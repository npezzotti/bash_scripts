#/usr/bin/env bash

# reverse a string

set -eu -o pipefail

STRING="hello"
STRING_LEN=${#STRING}

for (( i=$STRING_LEN-1; i>=0; i-- )); do
    REVERSED_STRING=${REVERSED_STRING:-""}${STRING:$i:1}
done

echo $REVERSED_STRING
