# fish-helix
helix key bindings for fish

# Installation

Dependencies: fish >= 3.6², GNU tools¹, perl.

1. Copy `*.fish` files inside `~/.config/fish/functions`.
2. Run `fish_helix_key_bindings`.

To undo, run `fish_default_key_bindings`.

¹ Should work with POSIX, but untested. Report any issues.

² fish >= 3.4 is sort of good enough. Clone fish-helix
[fish3.4](https://github.com/sshilovsky/fish-helix/tree/fish3.4) branch.

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
