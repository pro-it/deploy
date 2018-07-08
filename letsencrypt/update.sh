#!/bin/sh

PROIT_CURRENT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
PROIT_UPDATE_DIR="$PROIT_CURRENT_DIR/update/"

for f in $(ls "$PROIT_UPDATE_DIR"); do
    "$PROIT_UPDATE_DIR$f"
done
