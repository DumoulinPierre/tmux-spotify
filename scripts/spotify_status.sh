#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"


print_spotify_status() {
  connected=$($CURRENT_DIR/spotify_connected.sh 2>&1)
  if [ "$connected" = "OK" ]; then
    spotify_status_play=$(get_tmux_option "@spotify-status-play" ">")
    spotify_status_pause=$(get_tmux_option "@spotify-status-pause" "||")
    spotify_status_stop=$(get_tmux_option "@spotify-status-stop" "x")

    status=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'PlaybackStatus'|egrep -A 1 "string"|cut -b 26-|cut -d '"' -f 1|egrep -v ^$)

    if [ "$status" = "Playing" ]; then
      echo "$spotify_status_play"
    elif [ "$status" = "Paused" ]; then
      echo "$spotify_status_pause"
    elif [ "$status" = "Stopped" ]; then
      echo "$spotify_status_stop"
    else
      echo "ERROR"
    fi
  fi
}

main() {
  print_spotify_status
}
main
