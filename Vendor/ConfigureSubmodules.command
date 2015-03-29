#!/bin/bash

CURR_DIR=$(cd "$(dirname "$0")"; pwd)
cd "$CURR_DIR/../"

echo  "Enabling 'Sparse Checkout' (git config core.sparsecheckout true)"
git submodule foreach -q 'git config core.sparsecheckout true'

echo -e "Filtering out unneded files...\n"
git submodule foreach '[ "$name" == "Vendor/NSLogger" ] \
    && mkdir -p "$toplevel/.git/modules/$name/info/" \
    && echo "Client Logger/iOS/*.[hm]" > "$toplevel/.git/modules/$name/info/sparse-checkout" \
    && echo Updating "$toplevel/.git/modules/$name/info/sparse-checkout" \
    && git read-tree -mu HEAD'

echo -e "\nDone!"