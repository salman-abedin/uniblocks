#!/usr/bin/env sh

del="  |  "
# status=""

refresh-block 9
sleep 1

cat "$PANEL_FIFO" |
    while read -r line; do

        # grep -Ev "^#|^$" ~/.config/uniblocksrc |
        #     while read -r line; do
        #         if [ "$(echo "$line" | cut -d, -f3)" = 0 ]; then
        #             pipe_static \
        #                 "$(echo "$line" | cut -d, -f1)" \
        #                 "$(echo "$line" | cut -d, -f2)"
        #         else
        #             pipe_dynamic \
        #                 "$(echo "$line" | cut -d, -f1)" \
        #                 "$(echo "$line" | cut -d, -f2)" \
        #                 "$(echo "$line" | cut -d, -f3)"
        #         fi
        #     done

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

    done
