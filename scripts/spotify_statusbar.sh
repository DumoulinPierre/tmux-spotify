#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"

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
    local result=$(eval ${spotify_commands[$i]})
    all_interpolated=${all_interpolated/${spotify_interpolation[$i]}/$result}
  done
  echo "$all_interpolated"
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
