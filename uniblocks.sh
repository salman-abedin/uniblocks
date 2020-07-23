#!/usr/bin/env sh
#
# Wraps all of your status bar modules into a single string that updates only the part that has changed. This string can be used with any status bar application since Uniblocks itself handles all the updating.
# Dependencies: awk, grep, pgrep, mkfifo
# Usage: uniblocks -[g,u]

PANELFIFO=/tmp/panel_fifo
CONFIG=~/.config/uniblocksrc
DEL="  |  "

#---------------------------------------
# Used for parsing modules into the fifo
#---------------------------------------
parse() {
    # exec 3> $PANELFIFO
    while read -r line; do
        TEMP=${line#*,}
        SCRIPT=${TEMP%,*}
        TAG=${line%%,*}
        INTERVAL=${line##*,}
        if [ "$TAG" = W ]; then
            $SCRIPT > $PANELFIFO &
            # $SCRIPT >&3 &
        elif [ "$INTERVAL" = 0 ]; then
            echo "$TAG$($SCRIPT)" > $PANELFIFO &
            # echo "$TAG$($SCRIPT)" >&3 &
        else
            while :; do
                echo "$TAG$($SCRIPT)"
                sleep "$INTERVAL"
            done > $PANELFIFO &
            # done >&3 &
        fi
    done
    # exec 3>&-
}

trap 'rm -f $PANELFIFO; exit' INT

case $1 in
    --gen | -g)
        # Kill previously launched(if any) modules
        kill -- $(pgrep -f "$0" | grep -v $$) 2> /dev/null
        [ -e "$PANELFIFO" ] || mkfifo "$PANELFIFO"
        grep -Ev "^#|^$" $CONFIG | parse # Parse the modules into the fifo
        sleep 1                          # Give the fifo a little time to process all the module
        while read -r line; do           # Parse moudles out from the fifo
            TAGS=$(awk -F, '/^\w/{print $1}' $CONFIG)
            status=
            for tag in $TAGS; do
                case $line in
                    $tag*) echo "${line#$tag}" > /tmp/"$tag" ;;
                esac
                if [ -z "$status" ]; then
                    read -r status < /tmp/"$tag"
                else
                    read -r newstatus < /tmp/"$tag"
                    status="$status $DEL $newstatus"
                fi
            done
            printf "%s\r" "$status" # Print the result
        done < $PANELFIFO
        ;;
    --update | -u) [ -e $PANELFIFO ] && grep "^$2" $CONFIG | parse ;;
esac
