#!/usr/bin/env sh

kill -"$(($1 + 34))" "$(cat "$UBPID")"
