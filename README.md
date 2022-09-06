# fish-helix
helix key bindings for fish

WIP. Notable problems:

* word motion (w/b/e) is slow-ish, chance is not gonna be fixed without patching fish itself
* copy-paste works weirdly. Fortunately, undo/redo is in place.

Requires fish >= 3.4.

# Installation

1. Copy `*.fish` files inside `~/.config/fish/functions`
2. Run `fish_helix_key_bindings`

To undo, run `fish_default_key_bindings`.

# Tests

1. Install tmux.
2. Run `run-tests` script
