#!/usr/bin/env sh

pipe2fifo() {
    if [ "$3" = 0 ]; then
        echo "$1""$("$2")" > "$PANEL_FIFO" &
    else
        while :; do
            echo "$1""$($2)"
            sleep "$3"
        done > "$PANEL_FIFO" &
    fi
}

# line=$(grep "$1", ~/.config/uniblocksrc)

ns "$(awk -F, '{print $1" "$2" "$3}' ~/.config/uniblocksrc)"
# ns "$( echo "$line" | awk -F, '{print $1" "$2" "$3}')"

# pipe2fifo \
#     "$(echo "$line" | cut -d, -f1)" \
#     "$(echo "$line" | cut -d, -f2)" \
#     "$(echo "$line" | cut -d, -f3)"
