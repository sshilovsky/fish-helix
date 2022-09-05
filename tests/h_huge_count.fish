# Key input:
set -g _input 0123456789 Normal 999999999999h
# Expected state:
set -g _mode default
set -g _line 1
set -g _cursor 0
set -g _buffer 0123456789
set -g _selection 0