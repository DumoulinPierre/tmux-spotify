#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"

CUT_OPTIM=$(get_tmux_option "@spotify-cut-optim" 0)

spotify_interpolation=(
  "\#{spotify_status}"
  "\#{spotify_artist}"
  "\#{spotify_album}"
  "\#{spotify_title}"
)
spotify_commands=(
  "$CURRENT_DIR/spotify_status.sh"
  "$CURRENT_DIR/spotify_artist.sh"
  "$CURRENT_DIR/spotify_album.sh"
  "$CURRENT_DIR/spotify_title.sh"
)

do_interpolation() {
  local all_interpolated="$1"
  for ((i=0; i<${#spotify_commands[@]}; i++)); do
    if [ "$CUT_OPTIM" == "on" ]; then
      local result=$(eval "${spotify_commands[$i]} not_cut")
    else
      local result=$(eval ${spotify_commands[$i]})
    fi
    all_interpolated=${all_interpolated/${spotify_interpolation[$i]}/$result}
  done

  spotify_length_max=$(get_tmux_option "@spotify-length-max" 50)
  statusbar_length=$(expr length "$all_interpolated")

  if [ $spotify_length_max -eq 0 ]; then
    echo "$all_interpolated"
  elif [ $spotify_length_max -ge $statusbar_length ]; then
    echo "$all_interpolated"
  elif [ "$CUT_OPTIM" == "on" ]; then
    nb_char=$(($spotify_length_max-1))
    statusbar_cut=$(echo $all_interpolated | cut -c -$nb_char)
    echo -n $statusbar_cut
    echo "…"
  else
    echo "$all_interpolated"
  fi
}

print_spotify_statusbar() {
  connected=$($CURRENT_DIR/spotify_connected.sh 2>&1)
  if [ "$connected" = "OK" ]; then
    spotify_statusbar=$(get_tmux_option "@spotify-statusbar" "")
    new_spotify_statusbar=$(do_interpolation "$spotify_statusbar")
    echo "$new_spotify_statusbar"
  fi
}

main() {
  print_spotify_statusbar
}
main
