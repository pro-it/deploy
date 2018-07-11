#!/bin/sh

PRGIT_CURRENT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
PRGIT_UPDATE_DIR="$PRGIT_CURRENT_DIR/update/"

for f in $(ls "$PRGIT_UPDATE_DIR"); do
    "$PRGIT_UPDATE_DIR$f"
done
