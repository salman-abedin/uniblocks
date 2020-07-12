#!/usr/bin/env sh

PANELFIFO=/tmp/panel_fifo
UBPID=/tmp/ub_pid

parse() {
    while read -r line; do
        sstring=${line#*,}
        script=${sstring%,*}
        key=${line%%,*}
        interval=${line##*,}
        if [ "$key" = W ]; then
            $script > "$PANELFIFO" &
        elif [ "$interval" = 0 ]; then
            $script | sed "s/^/$key/" > "$PANELFIFO" &
        else
            while :; do
                $script | sed "s/^/$key/"
                # echo "$key$($script)"
                sleep "$interval"
            done > "$PANELFIFO" &
        fi
    done < /dev/stdin
}

case $1 in
    --server | -s)
        DUMMYFIFO=/tmp/dff
        generateblocks() {
            [ -e "$PANELFIFO" ] && rm "$PANELFIFO"
            mkfifo "$PANELFIFO"
            grep -Ev "^#|^$" ~/.config/uniblocksrc | parse
        }
        trap 'pgrep -P $$ | grep -v $$ | xargs kill -9; generateblocks' RTMIN+1

        echo $$ > "$UBPID"
        [ -e "$DUMMYFIFO" ] && rm -f "$DUMMYFIFO"
        mkfifo "$DUMMYFIFO"
        while :; do
            : < "$DUMMYFIFO" &
            wait
        done
        ;;
    --client | -c)
        del="|"
        kill -35 "$(cat "$UBPID")" # Send signal to start piping into the fifo
        sleep 1
        while read -r line; do
            keys=$(grep -Ev "^#|^$" ~/.config/uniblocksrc | cut -d, -f1)
            for key in $keys; do
                case $line in
                    $key*) echo "${line#?}" > ~/"$key" ;;
                esac
            done
            if [ "$2" ]; then
                printf "%s\r" "$(cat ~/"$2")"
            else
                status=
                for key in $keys; do
                    ! [ "$status" ] && status="$(cat ~/"$key")" && continue
                    status="$status $del $(cat ~/"$key")"
                done
                printf "%s\r" "$status"
            fi
        done < "$PANELFIFO"
        ;;
    refresh | -r) grep "^$2" ~/.config/uniblocksrc | parse ;;
    *) exit 1 ;;
esac
