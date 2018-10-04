#!/usr/bin/env bash

## BOOTSTRAP ##
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-bootstrap.sh"

import UI/Cursor

cat <<EOF
Cursor moving test:
  usage: hjkl -- move
         q -- exit
EOF

stty -echo
while read -rN1 key; do
  case $key in
    'h' ) UI.Cursor::moveLeft 1;;
    'j' ) UI.Cursor::moveDown 1;;
    'k' ) UI.Cursor::moveUp 1;;
    'l' ) UI.Cursor::moveRight 1;;
    'q' ) break;;
    * ) :;
  esac
done

stty echo
