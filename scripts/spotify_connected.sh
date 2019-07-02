#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"


print_spotify_status() {
  status=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'PlaybackStatus'|egrep -A 1 "string"|cut -b 26-|cut -d '"' -f 1|egrep -v ^$)

  if [ "$status" = "Playing" ]; then
    echo "OK"
  elif [ "$status" = "Paused" ]; then
    echo "OK"
  elif [ "$status" = "Stopped" ]; then
    echo "OK"
  else
    echo "ERROR"
  fi
}

main() {
  print_spotify_status
}
main
