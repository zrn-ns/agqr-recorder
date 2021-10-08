#!/usr/bin/env bash

set -eu

if [ ! -e "/agqr-recorder-data/config/config.yaml" ]; then
    cp -r /usr/src/app/agqr-recorder-config-dir-template/* /agqr-recorder-data/config/
fi

python3 -B /usr/src/app/scheduler.py
