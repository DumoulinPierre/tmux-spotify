#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"


print_spotify_album() {
  connected=$($CURRENT_DIR/spotify_connected.sh 2>&1)
  if [ "$connected" = "OK" ]; then
    spotify_album_max=$(get_tmux_option "@spotify-album-max" 0)

    album=`dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata'|egrep -A 1 "album"|egrep -v "album"|cut -b 44-|cut -d '"' -f 1|egrep -v ^$`
    album_length=$(expr length "$album")

    if [ $spotify_album_max -eq 0 ]; then
      echo $album
    elif [ $spotify_album_max -ge $album_length ]; then
      echo $album
    else
      nb_char=$(($spotify_album_max-3))
      album_cut=$(echo $album | cut -c -$nb_char)
      echo -n $album_cut
      echo "..."
    fi
  fi
}

main() {
  print_spotify_album
}
main
