#!/usr/bin/env bash

# generate a .gitignore file from github/gitignore templates

set -euo pipefail

GITIGNORE_PATH="$HOME/gitignore"
TEMPLATES=()
REFRESH=""
LIST=""

show_usage () {
    echo "Usage: ${0##*/} [options] template ...

Create a .gitignore file in the working directory 
using github/gitignore templates. Requires the 
github/gitignore be cloned locally.

    --path      path to local gitignore repo-
                defaults to \$HOME/gitignore
    --list      list available templates
    --refresh   pull remote changes
    --help      display usage
"
}

while [ $# -gt 0 ]; do
    case $1 in
        --path)
            GITIGNORE_PATH=$2
            shift
            ;;
        --list)
            LIST=1
            ;;
        --refresh)
            REFRESH=1
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            TEMPLATES+=($1)
            ;;
    esac
    shift
done

if ! [ -d $GITIGNORE_PATH ]; then
    echo "$GITIGNORE_PATH is not a directory"
    exit 1
fi

if [ -n "$REFRESH" ]; then
    echo "Pulling changes..."
    pushd $GITIGNORE_PATH > /dev/null
    git pull --quiet origin main
    exit 0
fi

if [ -n "$LIST" ]; then
    for file in $(find $GITIGNORE_PATH \
        \( -type f -o -type l \) \
        -name *.gitignore)
    do
        basename "$file" | cut -d. -f1
    done
    exit 0
fi

if [ ${#TEMPLATES[@]} -gt 0 ]; then
    for template in ${TEMPLATES[@]}; do
        echo "Copying template for $template..."
        find $GITIGNORE_PATH \
            \( -type l -o -type f \) \
            -name $template.gitignore \
            -exec cat '{}' >> .gitignore \;
    done
else
    show_usage
    exit 1
fi
