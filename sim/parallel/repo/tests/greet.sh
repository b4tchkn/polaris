#!/bin/bash
set -e
[ "$(bash greet.sh Ada)" = "Hello, Ada!" ]
[ "$(bash greet.sh 'Grace Hopper')" = "Hello, Grace Hopper!" ]
