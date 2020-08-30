#!/bin/sh
#
# Wraps all of your status bar modules into a single string
#     that updates only the part that has changed.
# Dependencies: mkfifo, sleep
# Usage: uniblocks -[g,u]

#===============================================================================
#                             Config
#===============================================================================

# Module Format = Tag,Script,Interval(in second)
# 0 for manually updated modules
# ❗ No extra whitespaces
CONFIG="\
sys,panel -s,3;
vol,panel -v,0;
wifi,panel -w,30;
dt,panel -d,60;
"
DELIMITER="   "

#===============================================================================
#                             Script
#===============================================================================

PANEL_FIFO=/tmp/panel_fifo2

parse() { # Used for parsing modules into the fifo
   while IFS= read -r line; do
      TEMP=${line#*,}
      SCRIPT=${TEMP%,*}
      TAG=${line%%,*}
      INTERVAL=${line##*,}
      if [ "$TAG" = W ]; then # BSPWM specific
         $SCRIPT > $PANEL_FIFO &
      elif [ "$INTERVAL" = 0 ]; then # Static modules
         echo "$TAG$($SCRIPT)" > $PANEL_FIFO &
      else
         while :; do # Dynamic modules
            echo "$TAG$($SCRIPT)"
            sleep "$INTERVAL"
         done > $PANEL_FIFO &
      fi
   done
}

get_config() {
   CURRENT_IFS=$IFS
   IFS=$(printf ';')
   for line in $CONFIG; do
      case $1 in
         -a) printf "%s" "$line" ;;
         -t) printf "%s" "${line%%,*}" ;;
         -m)
            case $line in
               *"$2"*) echo "${line#${line%%[![:space:]]*}}" && break ;;
            esac
            ;;
      esac
   done
   IFS=$CURRENT_IFS
}

generate() {
   mkfifo $PANEL_FIFO 2> /dev/null # Create fifo if it doesn't exist
   get_config -a | parse           # Parse the modules into the fifo
   sleep 1                         # Give the fifo a little time to process all the module

   trap 'kill 0' INT TERM QUIT EXIT # Setup up trap for cleanup
   while IFS= read -r line; do      # Parse moudles out from the fifo
      TAGS=$(get_config -t)         # Get tag lists from the config
      status=
      for tag in $TAGS; do
         case $line in
            # Match the correct tag with the fifo line
            $tag*) echo "${line#$tag}" > /tmp/"$tag" ;;
         esac
         # These lines are to do with the presenation
         [ -z "$status" ] && read -r status < /tmp/"$tag" && continue
         read -r newstatus < /tmp/"$tag"
         status="$status $DELIMITER $newstatus"
      done
      printf "\r%s" "$status" # Print the result
   done < $PANEL_FIFO
}

case $1 in
   --gen | -g) generate ;;
   --update | -u) [ -e $PANEL_FIFO ] && get_config -m "$2" | parse ;;
esac
