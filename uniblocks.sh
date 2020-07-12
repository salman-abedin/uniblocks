#!/usr/bin/env sh

[ "$PANELFIFO" ] || export PANELFIFO=/tmp/panel_fifo
[ "$UBPID" ] || export UBPID=/tmp/ub_pid

parse() {
    while read -r line; do
        sstring=${line#*,}
        script=${sstring%,*}
        key=${line%%,*}
        interval=${line##*,}
        if [ "$key" = W ]; then
            bspc subscribe report > "$PANELFIFO" &
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
    --server)
        DUMMYFIFO=/tmp/dff
        generateblocks() {
            [ -e "$PANELFIFO" ] && rm "$PANELFIFO"
            mkfifo "$PANELFIFO"
            grep -Ev "^#|^$" ~/.config/uniblocksrc | parse
            bspc subscribe report > "$PANELFIFO" &
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
    --client)
        del="  |  "
        kill -35 "$(cat "$UBPID")"
        sleep 1
        while read -r line; do
            case $line in
                d*) dt="${line#?}" ;;
                n*) not="${line#?}" ;;
                s*) sys="${line#?}" ;;
                v*) vol="${line#?}" ;;
                w*) wif="${line#?}" ;;
                W*)
                    wm=
                    IFS=':'
                    set -- ${line#?}
                    while [ "$#" -gt 0 ]; do
                        item="$1"
                        name="${item#?}"
                        case "$item" in
                            [mMfFoOuULG]*)
                                case "$item" in
                                    [FOU]*) name=" 🏚  " ;;
                                    f*) name=" 🕳  " ;;
                                    o*) name=" 🌴 " ;;
                                    LM | G*?) name="" ;;
                                    *) name="" ;;
                                esac
                                wm="${wm} ${name}"
                                ;;
                        esac
                        shift
                    done
                    ;;
            esac
            printf "%s\r" \
                "$wif $del $not $del $vol $del $wm $del $sys $del $dt"
        done < "$PANELFIFO"
        ;;
    refresh | -r) grep "^$2" ~/.config/uniblocksrc | parse ;;
    *) exit 1 ;;
esac
