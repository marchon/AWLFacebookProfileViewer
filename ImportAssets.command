#!/bin/bash

CURR_DIR=$(cd "$(dirname "$0")"; pwd)
cd "$CURR_DIR"
echo ""

SCRIPT_PATH=$CURR_DIR/Scripts/ImportImageAssets.php
EXPORT_DIR=$CURR_DIR/FacebookProfileViewerPrototypeDesign/ExportedSlices
ASSETS_DIR=$CURR_DIR/FacebookProfileViewerPrototype/Media.xcassets
if [ -r $SCRIPT_PATH ]; then
    echo "Removing old files..."
    find "$ASSETS_DIR" -type d -name '*.imageset' | xargs rm -rd
    php $SCRIPT_PATH -i "$EXPORT_DIR" -o "$ASSETS_DIR"
    echo "Performing cleanup..."
    find "$EXPORT_DIR" -name '*.png' -type f | xargs rm
else
    echo "warning: Unable to find script: $SCRIPT_PATH"
fi
echo "Done."
echo ""
