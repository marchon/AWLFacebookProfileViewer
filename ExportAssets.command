#!/bin/bash

EXPORT_CMD=sketchtool
command -v $EXPORT_CMD >/dev/null 2>&1 || { echo "$EXPORT_CMD utility is not found in your PATH. Please download it from http://bohemiancoding.com/sketch/tool. Aborting." >&2; exit 1; }

CURR_DIR=$(cd "$(dirname "$0")"; pwd)
cd "$CURR_DIR"
echo ""

SCRIPT_PATH=$CURR_DIR/Scripts/SketchAssetExport.php
if [ -r $SCRIPT_PATH ]; then
    DOC_FILE=$CURR_DIR/FacebookProfileViewerPrototypeDesign/FacebookProfileViewer.sketch
    ASSETS_DIR=$CURR_DIR/FacebookProfileViewerPrototype/Media.xcassets
    echo "Removing old files..."
    find "$ASSETS_DIR" -type d -name '*.imageset' | xargs rm -rd
    php $SCRIPT_PATH -i "$DOC_FILE" -o "$ASSETS_DIR" --page=iPhone
    
    ASSETS_DIR=$CURR_DIR/FacebookProfileViewerUI/Media.xcassets
    echo "Removing old files..."
    find "$ASSETS_DIR" -type d -name '*.imageset' | xargs rm -rd
    php $SCRIPT_PATH -i "$DOC_FILE" -o "$ASSETS_DIR" --page=Symbols
    
else
    echo "warning: Unable to find script: $SCRIPT_PATH"
fi
echo "Done."
echo ""