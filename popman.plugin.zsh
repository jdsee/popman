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
  local cmd_count=$(echo "$cmds" | wc -l)

  if [ "$cmd_count" -eq 0 ]; then
    return;
  fi

  zle redisplay

  local choice
  if [ "$cmd_count" -eq 1 ]; then
    choice=$(echo "$cmds" | head -n 1)
  else
    # TODO: This should happen in the tmux popup instead of direcly in the buffer
    choice=$(echo "$cmds" | fzf --layout=reverse --prompt="Select the tool you need help with: " --print-query | tr -d '\n')
  fi
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
