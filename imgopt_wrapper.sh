#!/bin/bash
approot="$(dirname "$(readlink -f "$0")")"
pidfile=/var/tmp/imgopt.pid
op="$1"

case $op in
    stop)
        [ -f "$pidfile" -a -s "$pidfile" ] && {
            kill "$(cat "$pidfile")"
            >&2 echo "killed imgopt."
        }
    ;;
    status)
        [ -f "$pidfile" -a -s "$pidfile" ] && {
            cat /proc/"$(cat "$pidfile")"/cmdline | tr '\0' ' '
            echo
        } || echo "imgopt is not running"
    ;;
    *)
        (
            flock -n 9 || {
                >&2 echo "imgopt is busy now"
                exit 1
            }
            >&2 echo "starting imgopt..."
            (
                "$approot"/imgopt "$@" &
                imgoptpid=$!
                echo $imgoptpid > "$pidfile"
                wait $imgoptpid
                rm "$pidfile"
            ) </dev/null >/dev/null 2>&1 &
        ) 9>/var/tmp/imgopt.lock 
    ;;
esac
