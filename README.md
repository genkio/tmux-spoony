# tmux-spoony

![tmux-spoony demo](./assets/tmuxSpoony.gif)

Small tmux copy-mode helpers for grabbing useful terminal text without replacing tmux copy mode.

Spoony adds one-key selectors for URLs, paths, shell commands, and whole lines. You still navigate with normal tmux copy-mode keys.

## Usage

Enter copy mode:

```text
prefix [
```

Move to a target line with normal tmux copy-mode navigation, then press:

```text
u  select URL on the cursor line
p  select path on the cursor line
c  select command after the prompt
x  select the whole line
o  open the selected text
y  yank the selected text
```

Spoony also replaces tmux's copy-mode position indicator with compact hints:

```text
u:url p:path c:cmd x:line o:open
```

Example:

```text
running on http://localhost:3000/practice
```

Move to that line, press `u`, then press `o`.

## Install

### TPM

Add Spoony to your `~/.tmux.conf` plugin list:

```tmux
set -g @plugin 'parwest/tmux-spoony'
```

Make sure the plugin line appears before TPM is initialized:

```tmux
run '~/.tmux/plugins/tpm/tpm'
```

Reload tmux config:

```sh
tmux source-file ~/.tmux.conf
```

Install the plugin with TPM:

```text
prefix + I
```

Or run TPM's installer directly:

```sh
~/.tmux/plugins/tpm/bin/install_plugins
```

Reload tmux once more after install:

```sh
tmux source-file ~/.tmux.conf
```

### Local Checkout

For local testing without TPM, run the plugin file directly:

```sh
tmux run-shell '/path/to/tmux-spoony/tmux-spoony.tmux'
```

To load a local checkout from `~/.tmux.conf`:

```tmux
run-shell '/path/to/tmux-spoony/tmux-spoony.tmux'
```

## Key Bindings

Spoony works without configuration. To override defaults, set options before loading the plugin:

```tmux
set -g @spoony-url-key 'u'
set -g @spoony-path-key 'p'
set -g @spoony-command-key 'c'
set -g @spoony-line-key 'x'
set -g @spoony-open-key 'o'
```

Any key can be disabled with `off`:

```tmux
set -g @spoony-open-key 'off'
```

The hint text can also be disabled or overridden:

```tmux
set -g @spoony-hints 'off'
set -g @spoony-hint-format 'u:url p:path c:cmd x:line o:open'
```

## Prompt Matching

The command selector defaults to a two-line zsh prompt whose command line starts with `> `:

```tmux
set -g @spoony-command-prompt-regex '^> +'
```

This matches commands like `> command` and `>  command`. If your prompt is different, set a more specific regex before loading Spoony.

## Requirements

- tmux with `copy-mode-vi` key tables
- Bash
- macOS `open` if you use Spoony's default `o` opener

Development/testing system:

- macOS
- tmux `3.6a`
- GNU Bash `5.3.9`
- `copy-mode-vi`
