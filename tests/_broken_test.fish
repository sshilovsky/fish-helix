# Example broken test
# Key input:
set -g _input 0123456789 Escape gh lll v lll
# Expected state:
set -g _mode visual
set -g _cursor 4 # actually, 6
set -g _buffer 0123456789
set -g _selection 3456