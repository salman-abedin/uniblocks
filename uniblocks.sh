#!/usr/bin/env sh

PANELFIFO=/tmp/panel_fifo
CONFIG=~/.config/uniblocksrc
DEL=" | "

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
    done < /dev/stdin
}

case $1 in
    --server | -s)
        DUMMYFIFO=/tmp/dff
        echo "Uniblocks listening for client requests"
        pgrep -f "$0 --server" | grep -v $$ | xargs kill -9 2> /dev/null
        [ -e "$PANELFIFO" ] && rm "$PANELFIFO"
        mkfifo "$PANELFIFO"
        #---------------------------------------
        # Parse the modules into the fifo
        #---------------------------------------
        grep -Ev "^#|^$" $CONFIG | parse
        [ -e "$DUMMYFIFO" ] && rm -f "$DUMMYFIFO"
        mkfifo "$DUMMYFIFO"
        while :; do
            : < "$DUMMYFIFO" &
            wait
        done
        ;;
    --client | -c)
        while read -r line; do
            TAGS=$(grep -Ev "^#|^$" $CONFIG | cut -d, -f1)
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
            if [ "$2" ]; then
                printf "%s\r" "$(cat /tmp/"$2")"
            else
                status=
                for tag in $TAGS; do
                    ! [ "$status" ] && status="$(cat /tmp/"$tag")" && continue
                    status="$status $DEL $(cat /tmp/"$tag")"
                done
                printf "%s\r" "$status"
            fi
        done < "$PANELFIFO"
        ;;
    --update | -u) [ -e "$PANELFIFO" ] && grep "^$2" $CONFIG | parse ;;
    *) exit 1 ;;
esac
