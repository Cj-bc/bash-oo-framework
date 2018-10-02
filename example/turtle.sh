#!/usr/bin/env bash

# WON'T WORK AT ALL

## BOOTSTRAP ##
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-bootstrap.sh"

## MAIN ##
import util/log util/exception util/tryCatch util/namedParameters util/class util/turtle

Turtle tl
$var:tl __init__ 'A'

$var:tl move 30 20
$var:tl penDown
$var:tl moveRight 20
$var:tl moveDown 10
$var:tl moveLeft 20
$var:tl moveUp 10
$var:tl penUp
$var:tl move 0 50
