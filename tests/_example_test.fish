# Example test
# Key input:
_input 0123456789 Normal gh lll v lll
# Expected state:
_mode visual # Possible values: default visual insert ...
_line 1
_cursor 6
_cursor --broken 4 # actually, 6
_buffer 0123456789
_selection 3456