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
  for ((i=0; i<${#title_regex_before[@]}; i++)); do
    filtered=$(echo "$filtered" | sed -E "s/${title_regex_before[$i]}/${title_regex_after[$i]}/g")
  done
  echo $filtered
}

print_spotify_title() {
  connected=$($CURRENT_DIR/spotify_connected.sh 2>&1)
  if [ "$connected" = "OK" ]; then
    spotify_title_max=$(get_tmux_option "@spotify-title-max" 0)

    title=`dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata'|egrep -A 1 "title"|egrep -v "title"|cut -b 44-|cut -d '"' -f 1|egrep -v ^$`
    title=$(delete_regex "$title")
    title_length=$(expr length "$title")

    if [ $NOT_CUT -eq 1 ]; then
      echo $title
    elif [ $spotify_title_max -eq 0 ]; then
      echo $title
    elif [ $spotify_title_max -ge $title_length ]; then
      echo $title
    else
      nb_char=$(($spotify_title_max-1))
      title_cut=$(echo $title | cut -c -$nb_char)
      echo -n $title_cut
      echo "…"
    fi
  fi
}

main() {
  print_spotify_title
}
main
