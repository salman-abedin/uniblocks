#!/usr/bin/env sh

PANELFIFO=/tmp/panel_fifo
CONFIG=~/.config/uniblocksrc
DEL="  |  "

#---------------------------------------
# Minimized "cat"
#---------------------------------------
cat() {
    while IFS= read -r line; do
        echo "$line"
    done < "$1"
}

#---------------------------------------
# Used for parsing modules into the fifo
#---------------------------------------
parse() {
    while read -r line; do
        sstring=${line#*,}
        script=${sstring%,*}
        tag=${line%%,*}
        interval=${line##*,}
        if [ "$tag" = W ]; then
            $script > "$PANELFIFO" &
        elif [ "$interval" = 0 ]; then
            $script | sed "s/^/$tag/" > "$PANELFIFO" &
        else
            while :; do
                $script | sed "s/^/$tag/"
                sleep "$interval"
            done > "$PANELFIFO" &
        fi
    done
}

case $1 in
    --gen | -g)
        [ -e "$PANELFIFO" ] && rm "$PANELFIFO" &&
            kill -9 $(pgrep -f "$0" | grep -v $$) 2> /dev/null
        mkfifo "$PANELFIFO"
        # ---------------------------------------
        # Parse the modules into the fifo
        # ---------------------------------------
        grep -Ev "^#|^$" $CONFIG | parse

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
                ! [ "$status" ] && status="$(cat /tmp/"$tag")" && continue
                status="$status $DEL $(cat /tmp/"$tag")"
            done
            printf "%s\r" "$status"
        done < "$PANELFIFO"
        ;;
    --update | -u) [ -e "$PANELFIFO" ] && grep "^$2" $CONFIG | parse ;;
    --kill | -k) kill -9 $(pgrep -f "$0") 2> /dev/null ;;
    *) exit 1 ;;
esac
