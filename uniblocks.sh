#!/usr/bin/env sh

[ "$PANEL_FIFO" ] || export PANEL_FIFO=/tmp/panelFifo

case $1 in
    --server)
        [ "$UNIBLOCKS_PID" ] || export UNIBLOCKS_PID=/tmp/ubPid
        DUMMYFIFO=/tmp/dff
        pipeToFifo() {
            if [ "$3" = 0 ]; then
                echo "$1""$("$2")" > "$PANEL_FIFO" &
            else
                while :; do
                    echo "$1""$($2)"
                    sleep "$3"
                done > "$PANEL_FIFO" &
            fi
        }
        generateBlocks() {
            [ -e "$PANEL_FIFO" ] && rm "$PANEL_FIFO"
            mkfifo "$PANEL_FIFO"
            grep -Ev "^#|^$" ~/.config/uniblocksrc |
                while read -r line; do
                    pipeToFifo \
                        "$(echo "$line" | cut -d, -f1)" \
                        "$(echo "$line" | cut -d, -f2)" \
                        "$(echo "$line" | cut -d, -f3)"
                done

            bspc subscribe report > "$PANEL_FIFO" &
        }
        trap 'canberra-gtk-play -i audio-volume-change && pipeToFifo v "volume" 0' RTMIN+1
        trap 'pipeToFifo m "mailbox" 0' RTMIN+2
        trap 'pipeToFifo n "noti-stat" 0' RTMIN+3
        trap 'pgrep -P $$ | grep -v $$ | xargs kill -9; generateBlocks' RTMIN+9

        echo $$ > "$UNIBLOCKS_PID"
        [ -e "$DUMMYFIFO" ] && rm -f "$DUMMYFIFO"
        mkfifo "$DUMMYFIFO"
        while :; do
            # read -r < "$DUMMYFIFO"
            : < "$DUMMYFIFO" &
            wait
        done
        ;;
    --client)
        del="  |  "
        refresh-block 9
        sleep 1
        while read -r line; do
            # keys=$(grep -Ev "^#|^$" ~/.config/uniblocksrc | cut -d, -f1)
            case $line in
                d*) dt="${line#?}" ;;
                m*) mail="${line#?}" ;;
                n*) not="${line#?}" ;;
                r*) rec="${line#?}" ;;
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
            # [ "$1" = wif ] && refresh-block <SIG> && echo "$wif" && exit
            printf "%s\r" \
                "$wif $del $mail $del $not $del $vol $del $wm $del $sys $del $dt $rec"
        done < "$PANEL_FIFO"
        ;;
    *) : ;;
esac
