#!/bin/bash

CURR_DIR=`dirname "$0"`
php -S 127.0.0.1:8888 -t "$CURR_DIR"