#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $# -ne 0 ]; then
  if [ "$1" == "not_cut" ]; then
    NOT_CUT=1
  else
    NOT_CUT=0
  fi
else
  NOT_CUT=0
fi

source "$CURRENT_DIR/helpers.sh"
source "$HOME/.tmux/spotify/conf.sh"

delete_regex() {
  filtered="$1"
  for ((i=0; i<${#album_regex_before[@]}; i++)); do
    filtered=$(echo "$filtered" | sed -E "s/${album_regex_before[$i]}/${album_regex_after[$i]}/g")
  done
  echo $filtered
}


print_spotify_album() {
  connected=$($CURRENT_DIR/spotify_connected.sh 2>&1)
  if [ "$connected" = "OK" ]; then
    spotify_album_max=$(get_tmux_option "@spotify-album-max" 0)

    album=`dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata'|egrep -A 1 "album"|egrep -v "album"|cut -b 44-|cut -d '"' -f 1|egrep -v ^$`
    album=$(delete_regex "$album")
    album_length=$(expr length "$album")

    if [ $NOT_CUT -eq 1 ]; then
      echo $album
    elif [ $spotify_album_max -eq 0 ]; then
      echo $album
    elif [ $spotify_album_max -ge $album_length ]; then
      echo $album
    else
      nb_char=$(($spotify_album_max-1))
      album_cut=$(echo $album | cut -c -$nb_char)
      echo -n $album_cut
      echo "…"
    fi
  fi
}

main() {
  print_spotify_album
}
main
