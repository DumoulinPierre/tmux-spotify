#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"


print_spotify_title() {
  connected=$($CURRENT_DIR/spotify_connected.sh 2>&1)
  if [ "$connected" = "OK" ]; then
    spotify_title_max=$(get_tmux_option "@spotify-title-max" 0)

    title=`dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata'|egrep -A 1 "title"|egrep -v "title"|cut -b 44-|cut -d '"' -f 1|egrep -v ^$`
    title_length=$(expr length "$title")

    if [ $spotify_title_max -eq 0 ]; then
      echo $title
    elif [ $spotify_title_max -ge $title_length ]; then
      echo $title
    else
      nb_char=$(($spotify_title_max-3))
      title_cut=$(echo $title | cut -c -$nb_char)
      echo -n $title_cut
      echo "..."
    fi
  fi
}

main() {
  print_spotify_title
}
main
