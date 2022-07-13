#!/bin/sh

# shellcheck disable=SC2009
ps -eo pid,etime,comm | grep -E "$MAX_MINUTES:.. ffmpe[g]" | awk '{print $1}' | xargs -I {} -r kill "{}" || true

if ! (netstat -an | grep ":$CONTROLLER_PORT" >/dev/null);
then
    exit 1
fi
