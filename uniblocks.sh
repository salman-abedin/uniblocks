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
            # bspc subscribe report > "$PANELFIFO" &
        elif [ "$interval" = 0 ]; then
            echo "$key$($script)" > "$PANELFIFO" &
        else
            while :; do
                echo "$key$($script)"
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

            # Perse in modules into the fifo
            grep -Ev "^#|^$" ~/.config/uniblocksrc | parse
            # bspc subscribe report > "$PANELFIFO"
            # bspc subscribe report > "$PANELFIFO" &
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

        # Perse out modules from the fifo
        while read -r line; do
            keys=$(grep -Ev "^#|^$" ~/.config/uniblocksrc | cut -d, -f1)
            for key in $keys; do
                case $line in
                    # W*)
                    #     line=${line#*:}
                    #     line=${line%:L*}
                    #     IFS=:
                    #     set $line
                    #     wm=
                    #     while :; do
                    #         case $1 in
                    #             [FOU]*) name=🏚 ;;
                    #             f*) name=🕳 ;;
                    #             o*) name=🌴 ;;
                    #             *) break ;;
                    #         esac
                    #         wm="$wm $name"
                    #         shift
                    #     done
                    #     echo "$wm" > ~/W
                    #     ;;
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
