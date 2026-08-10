# shellcheck disable=SC1090,SC2148

# Only load this configuration for interactive shells.
if [[ $- != *i* ]]; then
  return 0 2>/dev/null || exit 0
fi

# Common shell history settings.
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# Load modular bash fragments from ~/.bash.
config_dir="$HOME/.bash"
if [[ -d "$config_dir" ]]; then
  shopt -s nullglob
  for config_file in "$config_dir"/*.sh; do
    [[ -f "$config_file" ]] || continue
    # shellcheck source=/dev/null
    . "$config_file"
  done
  shopt -u nullglob
fi

unset config_dir config_file

# Enable color support for ls/grep when available.
if command -v dircolors >/dev/null 2>&1; then
  if [[ -f "$HOME/.dircolors" ]]; then
    eval "$(dircolors -b "$HOME/.dircolors")"
  else
    eval "$(dircolors -b)"
  fi
fi