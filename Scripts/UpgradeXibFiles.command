#!/bin/bash

CURR_DIR=$(cd "$(dirname "$0")"; pwd)
cd "$CURR_DIR/../"
find . -type f \( -iname "*.xib" -o -iname "*.storyboard" \) -print0 | xargs -0 -I{} xcrun ibtool --upgrade {}