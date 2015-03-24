#!/bin/bash

EXPORT_CMD=sketchtool
command -v $EXPORT_CMD >/dev/null 2>&1 || { echo "$EXPORT_CMD utility is not found in your PATH. Please download it from http://bohemiancoding.com/sketch/tool. Aborting." >&2; exit 1; }

CURR_DIR=$(cd "$(dirname "$0")"; pwd)
cd "$CURR_DIR"
echo ""

SCRIPT_PATH=$CURR_DIR/Scripts/SketchStyleKitExport.php
DOC_FILE=$CURR_DIR/Design/FBPV.sketch
STYLEKIT_FILE=$CURR_DIR/UI/SketchStyleKit.swift

if [ -r $SCRIPT_PATH ]; then
    php $SCRIPT_PATH -i "$DOC_FILE" -o "$STYLEKIT_FILE"
else
    echo "warning: Unable to find script: $SCRIPT_PATH"
fi
echo "Done."
echo ""
