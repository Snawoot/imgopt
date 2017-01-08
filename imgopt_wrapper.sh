#!/bin/bash
approot=$(dirname "$(readlink -f "$0")")
pidfile=/var/tmp/imgopt.pid

(
    flock -n 9 || {
        >&2 echo "imgopt is busy now"
        exit 1
    }
    >&2 echo "starting imgopt..."
    (
        "$approot"/imgopt "$@" </dev/null >/dev/null 2>&1 &
        imgoptpid=$!
        echo $imgoptpid > "$pidfile"
        wait $imgoptpid
        rm "$pidfile"
    ) </dev/null >/dev/null 2>&1 &
) 9>/var/tmp/imgopt.lock 
