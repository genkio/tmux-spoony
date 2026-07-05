#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

url_key="$(tmux show-option -gqv @spoony-url-key)"
path_key="$(tmux show-option -gqv @spoony-path-key)"
command_key="$(tmux show-option -gqv @spoony-command-key)"
ip_key="$(tmux show-option -gqv @spoony-ip-key)"
line_key="$(tmux show-option -gqv @spoony-line-key)"
open_key="$(tmux show-option -gqv @spoony-open-key)"

if [ -z "$url_key" ]; then
  url_key="u"
fi

if [ -z "$path_key" ]; then
  path_key="p"
fi

if [ -z "$command_key" ]; then
  command_key="c"
fi

if [ -z "$ip_key" ]; then
  ip_key="i"
fi

if [ -z "$line_key" ]; then
  line_key="x"
fi

if [ -z "$open_key" ]; then
  open_key="o"
fi

bind_copy_mode_key() {
  key="$1"
  shift

  if [ -n "$key" ] && [ "$key" != "off" ]; then
    tmux bind-key -T copy-mode-vi "$key" "$@"
  fi
}

hint_item() {
  key="$1"
  label="$2"

  if [ -n "$key" ] && [ "$key" != "off" ]; then
    printf '%s:%s ' "$key" "$label"
  fi
}

configure_hints() {
  hints_enabled="$(tmux show-option -gqv @spoony-hints)"
  current_format="$(tmux show-option -gqv copy-mode-position-format)"
  base_format="$(tmux show-option -gqv @spoony-copy-mode-position-format-base)"

  if [[ "$current_format" != *"@spoony-hint-text"* ]]; then
    base_format="$current_format"
    tmux set-option -gq @spoony-copy-mode-position-format-base "$base_format"
  elif [ -z "$base_format" ]; then
    return
  fi

  if [ "$hints_enabled" = "off" ]; then
    if [[ "$current_format" == *"@spoony-hint-text"* ]]; then
      tmux set-option -gq copy-mode-position-format "$base_format"
    fi
    tmux set-option -guq @spoony-hint-text
    return
  fi

  hint_text="$(tmux show-option -gqv @spoony-hint-format)"
  if [ -z "$hint_text" ]; then
    hint_text="$(
      hint_item "$url_key" url
      hint_item "$path_key" path
      hint_item "$command_key" cmd
      hint_item "$ip_key" ip
      hint_item "$line_key" line
      hint_item "$open_key" open
    )"
    hint_text="${hint_text% }"
  fi

  if [ -z "$hint_text" ]; then
    return
  fi

  tmux set-option -gq @spoony-hint-text "$hint_text"

  tmux set-option -gq copy-mode-position-format "#[align=right]#{@spoony-hint-text}"
}

unbind_stale_command_key() {
  old_command_key="m"

  if [ "$command_key" = "$old_command_key" ]; then
    return
  fi

  old_binding="$(tmux list-keys -T copy-mode-vi "$old_command_key" 2>/dev/null || true)"
  if [[ "$old_binding" == *"select-on-line.sh"* && "$old_binding" == *" command "* ]]; then
    tmux unbind-key -T copy-mode-vi "$old_command_key"
  fi
}

select_script="$(printf '%q' "$CURRENT_DIR/scripts/select-on-line.sh")"
open_script="$(printf '%q' "$CURRENT_DIR/scripts/open-selection.sh")"

unbind_stale_command_key
configure_hints

bind_copy_mode_key "$url_key" run-shell "bash $select_script url '#{pane_id}'"
bind_copy_mode_key "$path_key" run-shell "bash $select_script path '#{pane_id}'"
bind_copy_mode_key "$command_key" run-shell "bash $select_script command '#{pane_id}'"
bind_copy_mode_key "$ip_key" run-shell "bash $select_script ip '#{pane_id}'"
bind_copy_mode_key "$line_key" 'send-keys -X back-to-indentation ; send-keys -X begin-selection ; send-keys -X end-of-line'
bind_copy_mode_key "$open_key" send-keys -X copy-pipe-and-cancel "bash $open_script '#{pane_id}'"
