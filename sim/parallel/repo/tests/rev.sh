#!/bin/bash
set -e
[ "$(bash rev.sh abc)" = cba ]
[ "$(bash rev.sh 'a b')" = "b a" ]
