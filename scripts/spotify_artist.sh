#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"


print_spotify_artist() {
  connected=$($CURRENT_DIR/spotify_connected.sh 2>&1)
  if [ "$connected" = "OK" ]; then
    spotify_artist_max=$(get_tmux_option "@spotify-artist-max" 0)

    artist=`dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata'|egrep -A 2 "artist"|egrep -v "artist"|egrep -v "array"|cut -b 27-|cut -d '"' -f 1|egrep -v ^$`
    artist_length=$(expr length "$artist")

    if [ $spotify_artist_max -eq 0 ]; then
      echo $artist
    elif [ $spotify_artist_max -ge $artist_length ]; then
      echo $artist
    else
      nb_char=$(($spotify_artist_max-3))
      artist_cut=$(echo $artist | cut -c -$nb_char)
      echo -n $artist_cut
      echo "..."
    fi
  fi
}

main() {
  print_spotify_artist
}
main
