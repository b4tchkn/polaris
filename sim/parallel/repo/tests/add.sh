#!/bin/bash
set -e
[ "$(bash add.sh 2 3)" = 5 ]
[ "$(bash add.sh -4 10)" = 6 ]
