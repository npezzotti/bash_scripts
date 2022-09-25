#!/bin/bash

#################################################
# Compresses files over 10M in a given directory.
#################################################

set -e

display_usage() 
{
	echo "Usage: $(basename $0) <directory> [<file_pattern>]"
}

if [ $UID -ne 0 ]
then
    echo "This script must be run as root." >&2
    exit 1
fi

if [ $# -lt 1 ]
then
    display_usage
    exit 1
fi

DIR=$1
FILE_SIZE="10M"
PATTERN=$2

FILES=$(find ${DIR} -type f -size ${FILE_SIZE} -regex ${PATTERN:-.*\/.*\.log})

for file in ${FILES[@]}
do
    echo "$(date "+%F %T %Z"): compressing ${file}..."

    INDEX=1
    while [ -f ${file}.${INDEX}.gz ]
    do
        ((INDEX++))
    done

    gzip -k -S .${INDEX}.gz ${file}
    cat /dev/null > ${file}
done
