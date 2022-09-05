# fish-helix
helix key bindings for fish

So far only very basic stuff, notably copy-paste works weirdly, and word motions don't match helix behavior.

Probably requires fish >= 3.4.1.

# Installation

1. Copy `*.fish` files inside `~/.config/fish/functions`
2. Run `fish_helix_key_bindings`

To undo, run `fish_default_key_bindings`.

# Tests

Test require fish >= 3.4

1. Install tmux.
2. Run `run-tests` script
