#!/bin/bash

cd $HOME

set -ex

: ${DEST_DIR:=intellij-community}
: ${ARCHIVE_NAME:=intellij-community}
RESTORE_DIR="$HOME/.restore.tmp"

if [[ -d "$DEST_DIR" ]]; then
  echo "Folder $DEST_DIR exists, bail out."
  exit 0
fi

rm -fr "$RESTORE_DIR"
mkdir -p "$RESTORE_DIR"

echo "Restoring archive $ARCHIVE_NAME ..."

cs ar restore -C "$RESTORE_DIR" "$ARCHIVE_NAME"

for fn in $(find "$RESTORE_DIR" -name '*.tar.gz'); do
  echo "Unpacking $fn ..."
  tar -C "$HOME" -zxf "$fn"
done

for fn in $(find "$RESTORE_DIR" -name '*.tar'); do
  echo "Unpacking $fn ..."
  tar -C "$HOME" -xf "$fn"
done
