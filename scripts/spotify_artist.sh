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
  for ((i=0; i<${#artist_regex_before[@]}; i++)); do
    filtered=$(echo "$filtered" | sed -E "s/${artist_regex_before[$i]}/${artist_regex_after[$i]}/g")
  done
  echo $filtered
}


print_spotify_artist() {
  connected=$($CURRENT_DIR/spotify_connected.sh 2>&1)
  if [ "$connected" = "OK" ]; then
    spotify_artist_max=$(get_tmux_option "@spotify-artist-max" 0)

    artist=`dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata'|egrep -A 2 "artist"|egrep -v "artist"|egrep -v "array"|cut -b 27-|cut -d '"' -f 1|egrep -v ^$`
    artist=$(delete_regex "$artist")
    artist_length=$(expr length "$artist")

    if [ $NOT_CUT -eq 1 ]; then
      echo $artist
    elif [ $spotify_artist_max -eq 0 ]; then
      echo $artist
    elif [ $spotify_artist_max -ge $artist_length ]; then
      echo $artist
    else
      nb_char=$(($spotify_artist_max-1))
      artist_cut=$(echo $artist | cut -c -$nb_char)
      echo -n $artist_cut
      echo "…"
    fi
  fi
}

main() {
  print_spotify_artist
}
main
