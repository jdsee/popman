#!/bin/env zsh

extract_commands() {
  local cmd_line=$1
  echo "$cmd_line" \
    | sed "s/'[^']*'//g; s/-\S*//g" \
    | xargs \
    | awk -F'\\$\\(|)|\\|' '{
        for (i=1; i<=NF; i++) {
          split($i, a, " ");
          if (a[1] == "sudo" || a[1] == "xargs" && a[2] != "") {
            print a[1]
            print a[2]
          }
          else if (a[1] != "") {
            print a[1]
          }
        }
      }' \
    | uniq \
    | tac
}

popman() {
  local curr_buffer=$BUFFER
  BUFFER=""

  local cmds=$(extract_commands "$curr_buffer")

  if [[ -z $curr_buffer ]]; then
    echo "hi"
    return;
  fi

  zle redisplay

  local choice=$(echo "$cmds" | fzf)
  if [ "${TMUX}" ]; then
    tmux popup -EE -h 90% -w 90% man "$choice"
  else
    man "$choice"
  fi

  BUFFER=$curr_buffer
  CURSOR=$#BUFFER
  zle redisplay
}

zle -N popman
bindkey '^K' popman
