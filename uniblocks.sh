#!/usr/bin/env sh

case $1 in
    --server)
        [ "$PANEL_FIFO" ] || export PANEL_FIFO=/tmp/panelFifo
        [ "$REC_PID" ] || export REC_PID=/tmp/recPid
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
        :
        ;;
    *) : ;;
esac
