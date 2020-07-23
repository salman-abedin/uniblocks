#!/usr/bin/env sh
#
# Wraps all of your status bar modules into a single string that updates only the part that has changed. This string can be used with any status bar application since Uniblocks itself handles all the updating.
# Dependencies: sed, grep, pgrep, mkfifo
# Usage: uniblocks -[g,u]

PANELFIFO=/tmp/panel_fifo
CONFIG=~/.config/uniblocksrc
DEL="  |  "

#---------------------------------------
# Used for parsing modules into the fifo
#---------------------------------------
parse() {
    while read -r line; do
        TEMP=${line#*,}
        SCRIPT=${TEMP%,*}
        TAG=${line%%,*}
        INTERVAL=${line##*,}

        if [ "$TAG" = W ]; then
            $SCRIPT > "$PANELFIFO" &
        elif [ "$INTERVAL" = 0 ]; then
            $SCRIPT | sed "s/^/$TAG/" > "$PANELFIFO" &
        else
            while :; do
                $SCRIPT | sed "s/^/$TAG/"
                sleep "$INTERVAL"
            done > "$PANELFIFO" &
        fi
    done
}

trap 'kill -- -$$' INT

case $1 in
    --gen | -g)
        [ -e "$PANELFIFO" ] && rm "$PANELFIFO" &&
            kill -9 $(pgrep -f "$0" | grep -v $$) 2> /dev/null
        mkfifo "$PANELFIFO"
        # ---------------------------------------
        # Parse the modules into the fifo
        # ---------------------------------------
        grep -Ev "^#|^$" $CONFIG | parse
        sleep 1

        while read -r line; do
            TAGS=$(awk -F, '/^\w/{print $1}' $CONFIG)
            #---------------------------------------
            # Parse moudles out from the fifo
            #---------------------------------------
            for tag in $TAGS; do
                case $line in
                    $tag*) echo "${line#$tag}" > /tmp/"$tag" ;;
                esac
            done

            #---------------------------------------
            # Print the result
            #---------------------------------------
            status=
            for tag in $TAGS; do
                if [ -z "$status" ]; then
                    read -r status < /tmp/"$tag"
                else
                    read -r newstatus < /tmp/"$tag"
                    status="$status $DEL $newstatus"
                fi
            done
            printf "%s\r" "$status"
        done < "$PANELFIFO"
        ;;
    --update | -u) [ -e "$PANELFIFO" ] && grep "^$2" $CONFIG | parse ;;
    *) exit 1 ;;
esac
