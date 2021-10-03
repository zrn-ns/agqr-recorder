#!/usr/bin/env bash

set -eu

if [ ! -e "/agqr-recorder-data/config.yaml" ]; then
    cp -r /usr/src/app/agqr-recorder-data-template/* /agqr-recorder-data/
fi

python3 -B /usr/src/app/scheduler.py
