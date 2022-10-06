# fish-helix
helix key bindings for fish

This is the outdated version for fish < 3.6.

Notable problems:

* copy-paste works weirdly. Fortunately, undo/redo is in place.
* a & i don't do not respect current selection.

These and many other features
need [fish PR #9215](https://github.com/fish-shell/fish-shell/pull/9215)
merged into fish 3.6.


# Installation

Dependencies: fish >= 3.4, GNU tools¹, perl.

1. Copy `*.fish` files inside `~/.config/fish/functions`.
2. Run `fish_helix_key_bindings`.

To undo, run `fish_default_key_bindings`.

¹ Should work with POSIX, but untested. Report any issues.

# Tests

1. Install tmux and inotify-tools.
2. Run `run-tests` script

# Configuration

`fish_helix_command` function provides some helix-like actions. Use it for custom bindings.

## IMPORTANT!!!

When defining your own bindings using fish_helix_command, be aware that it can break
stuff sometimes.

It is safe to define a binding consisting of a lone call to fish_helix_command.
Calls to other functions and executables are allowed along with it, granted they don't mess
with fish's commandline buffer.

Mixing multiple fish_helix_commandline and commandline calls in one binding MAY trigger issues.
Nothing serious, but don't be surprised. Just test it.
