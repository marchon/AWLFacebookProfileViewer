#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo -e "Illegal number of parameters. \n\t Usage: $(basename $0) {path} {projectName}"
    exit 1
fi

CURR_DIR=`dirname $0`
cd "$CURR_DIR"
SCRIPT_PATH=$CURR_DIR/CheckFileHeaders.php
if [ -r $SCRIPT_PATH ]; then
    php $SCRIPT_PATH "$1" $2
else
    echo "warning: Unable to find script: $SCRIPT_PATH"
fi
