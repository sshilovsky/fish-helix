# fish-helix
helix key bindings for fish

WIP. Notable problems:

* word motion (w/b/e) is slow-ish.
* copy-paste works weirdly. Fortunately, undo/redo is in place.

Requires fish >= 3.4.

# Installation

1. Copy `*.fish` files inside `~/.config/fish/functions`
2. Run `fish_helix_key_bindings`

To undo, run `fish_default_key_bindings`.

# Tests

1. Install tmux and inotify-tools.
2. Run `run-tests` script

# Configuration

`fish_helix_commandline` function provides some helix-like actions. Use it for custom bindings.

## IMPORTANT!!!

When defining your own bindings using fish_helix_commandline, be aware that it can break
stuff sometimes.

It is safe to define a binding consisting of a lone call to fish_helix_commandline.
Calls to other functions and executables are allowed along with it, granted they don't mess
with fish's commandline buffer.

Mixing multiple fish_helix_commandline and commandline calls in one binding MAY trigger issues.
Nothing serious, but don't be surprised. Just test it.
