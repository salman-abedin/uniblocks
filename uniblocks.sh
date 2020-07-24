#!/usr/bin/env sh
#
# Wraps all of your status bar modules into a single string that updates only the part that has changed. This string can be used with any status bar application since Uniblocks itself handles all the updating.
# Dependencies: awk, grep, pgrep, mkfifo
# Usage: uniblocks -[g,u]

PANELFIFO=/tmp/panel_fifo
CONFIG=~/.config/uniblocksrc
DELIMITER="  |  "

parse() {               # Used for parsing modules into the fifo
    exec 3<> $PANELFIFO # Set File Descriptor for addressing convenience
    while read -r line; do
        TEMP=${line#*,}
        SCRIPT=${TEMP%,*}
        TAG=${line%%,*}
        INTERVAL=${line##*,}
        if [ "$TAG" = W ]; then # BSPWM specific
            $SCRIPT >&3 &
        elif [ "$INTERVAL" = 0 ]; then # Static modules
            echo "$TAG$($SCRIPT)" >&3 &
        else
            while :; do # Dynamic modules
                echo "$TAG$($SCRIPT)"
                sleep "$INTERVAL"
            done >&3 &
        fi
    done
    exec 3<&- # Unset FD
}

scan() { # Used for getting config of the module(s)
    while IFS= read -r line; do
        if [ -n "$1" ]; then
            case $line in
                "$1"*) echo "$line" ;;
            esac
        else
            case $line in
                [[:alnum:]]*) echo "$line" ;;
            esac
        fi
    done < $CONFIG
}

case $1 in
    --gen | -g)
        kill -- $(pgrep -f "$0" | grep -v $$) 2> /dev/null # Bg jobs cleanup
        [ -e "$PANELFIFO" ] || mkfifo "$PANELFIFO"         # Create fifo if it doesn't exist
        scan | parse                                       # Parse the modules into the fifo
        sleep 1                                            # Give the fifo a little time to process all the module
        trap 'rm -f $PANELFIFO; exit' INT TERM QUIT EXIT   # Setup up trap for cleanup
        while IFS= read -r line; do                        # Parse moudles out from the fifo
            TAGS=$(awk -F, '/^\w/{print $1}' $CONFIG)      # Get tag lists from the config
            status=
            for tag in $TAGS; do
                case $line in
                    $tag*) echo "${line#$tag}" > /tmp/"$tag" ;; # Match the correct tag with the fifo line
                esac
                # These lines are to do with presenation
                [ -z "$status" ] && read -r status < /tmp/"$tag" && continue
                read -r newstatus < /tmp/"$tag"
                status="$status $DELIMITER $newstatus"
            done
            printf "%s\r" "$status" # Print the result
        done < $PANELFIFO
        ;;
    --update | -u) [ -e $PANELFIFO ] && scan "$2" | parse ;;
esac
