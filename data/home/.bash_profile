# shellcheck disable=SC1090,SC2148

# Load the shell profile and interactive bash configuration for login shells.
for config_file in "$HOME/.profile" "$HOME/.bashrc"; do
  if [[ -f "$config_file" ]]; then
    . "$config_file"
  fi
done