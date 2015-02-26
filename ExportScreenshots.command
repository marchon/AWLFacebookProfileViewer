#!/bin/bash

EXPORT_CMD=sketchtool
command -v $EXPORT_CMD >/dev/null 2>&1 || { echo "$EXPORT_CMD utility is not found in your PATH. Please download it from http://bohemiancoding.com/sketch/tool. Aborting." >&2; exit 1; }

CURR_DIR=$(cd "$(dirname "$0")"; pwd)
cd "$CURR_DIR"
echo ""

$EXPORT_CMD export artboards --items="Posts, Friends" --overwriting=YES --save-for-web=YES "$CURR_DIR/Design/FBPV.sketch"
mv "$CURR_DIR/Friends@2x.png" "$CURR_DIR/Screenshot-Friends.png"
mv "$CURR_DIR/Posts@2x.png" "$CURR_DIR/Screenshot-Posts.png"
echo "Done."
echo ""
