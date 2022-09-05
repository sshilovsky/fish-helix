# Key input:
set -g _input 0123456789 Normal gh 999999999999l
# Expected state:
set -g _mode default
set -g _line 1
set -g _cursor 10
set -g _buffer 0123456789
set -g _selection ""