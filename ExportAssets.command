#!/bin/bash

EXPORT_CMD=sketchtool
command -v $EXPORT_CMD >/dev/null 2>&1 || { echo "$EXPORT_CMD utility is not found in your PATH. Please download it from http://bohemiancoding.com/sketch/tool. Aborting." >&2; exit 1; }

CURR_DIR=$(cd "$(dirname "$0")"; pwd)
cd "$CURR_DIR"
echo ""

SCRIPT_PATH=$CURR_DIR/Scripts/SketchAssetExport.php
DOC_FILE=$CURR_DIR/Design/FBPV.sketch

if [ -r $SCRIPT_PATH ]; then
    
    # Real Application
    
    ASSETS_DIR=$CURR_DIR/FBPV/Media.xcassets
    echo "Removing old files..."
    find "$ASSETS_DIR" -type d -name '*.imageset' | xargs -I{} rm -rd "{}"
    php $SCRIPT_PATH -i "$DOC_FILE" -o "$ASSETS_DIR" --page=Symbols
    echo ""
    
    ASSETS_DIR=$CURR_DIR/FBPV/Images.xcassets
    echo "Removing old files..."
    find "$ASSETS_DIR" -type d -name '*.imageset' | xargs -I{} rm -rd "{}"
    php $SCRIPT_PATH -i "$DOC_FILE" -o "$ASSETS_DIR" --page=AppIcons
    # Removing unneded 1x images
    find "$ASSETS_DIR" -type f -name '*@1x.png' | xargs -I{} rm -f "{}"
    echo ""
    
    # Prototype Application
    cp -fR "$ASSETS_DIR" "$CURR_DIR/FBPVPrototype"
    
    ASSETS_DIR=$CURR_DIR/FBPVPrototype/Media.xcassets
    echo "Removing old files..."
    find "$ASSETS_DIR" -type d -name '*.imageset' | xargs -I{} rm -rd "{}"
    php $SCRIPT_PATH -i "$DOC_FILE" -o "$ASSETS_DIR" --page=iPhone
    
else
    echo "warning: Unable to find script: $SCRIPT_PATH"
fi
echo "Done."
echo ""
