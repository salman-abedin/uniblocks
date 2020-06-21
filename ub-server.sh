#!/usr/bin/env sh

[ "$PANEL_FIFO" ] || export PANEL_FIFO=/tmp/panelFifo
[ "$REC_PID" ] || export REC_PID=/tmp/recPid
[ "$UNIBLOCKS_PID" ] || export UNIBLOCKS_PID=/tmp/ubPid
dummy_fifo=/tmp/dff

pipe_dynamic() { while :; do
    echo "$1""$($2)"
    sleep "$3"
done > "$PANEL_FIFO" & }

pipe_static() { echo "$1""$("$2")" > "$PANEL_FIFO" & }

generate_blocks() {
    [ -e "$PANEL_FIFO" ] && rm "$PANEL_FIFO"
    mkfifo "$PANEL_FIFO"
    grep -Ev "^#|^$" ~/.config/uniblocksrc |
        while read -r line; do
            if [ "$(echo "$line" | cut -d, -f3)" = 0 ]; then
                pipe_static \
                    "$(echo "$line" | cut -d, -f1)" \
                    "$(echo "$line" | cut -d, -f2)"
            else
                pipe_dynamic \
                    "$(echo "$line" | cut -d, -f1)" \
                    "$(echo "$line" | cut -d, -f2)" \
                    "$(echo "$line" | cut -d, -f3)"
            fi
        done
    bspc subscribe report > "$PANEL_FIFO" &
}

trap 'canberra-gtk-play -i audio-volume-change && pipe_static v "volume"' RTMIN+1
trap 'pipe_static m "mailbox"' RTMIN+2
trap 'pipe_static n "noti-stat"' RTMIN+3
trap 'pgrep -P $$ | grep -v $$ | xargs kill -9; generate_blocks' RTMIN+9

echo $$ > "$UNIBLOCKS_PID"
[ -e "$dummy_fifo" ] && rm -f "$dummy_fifo"
mkfifo "$dummy_fifo"
# wait
while :; do
    # read -r < "$dummy_fifo"
    : < "$dummy_fifo" &
    wait
done
