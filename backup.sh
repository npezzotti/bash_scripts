#!/usr/bin/env bash

# backup a list of directories

show_usage () {
    echo "Usage: $0 directory ..."
    exit 1
}

if [ ! $# -ge 1 ]; then
    show_usage
fi

DATE=$(date "+%Y-%m-%d-%H:%M%:%S")

for dir in $@; do
    if [ -d $dir ]; then
        tar -czvf $dir.$DATE.tar.gz $dir
        rm -r $dir
    else
        echo "$dir: No such directory"
    fi
done
