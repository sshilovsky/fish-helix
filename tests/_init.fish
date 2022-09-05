# Initialization file for the tests

# TODO error handling

set fifo "$argv[1]"
set out "$argv[2]"
echo $fish_pid "$TMUX_PANE" > $fifo
set result ok

function validate_val -a caption value expected
    if test -n "$expected" -a "$value" != "$expected"
        echo "$caption $value ("$expected" expected)" >> "$out"
        set result fail
    else
        echo "$caption $value" >> "$out"
    end
end

function validate
    validate_val "Bind mode:        " "$fish_bind_mode" "$_mode"
    validate_val "Cursor line:      " "$(commandline --line)" "$_line"
    validate_val "Cursor position:  " "$(commandline --cursor)" "$_cursor"
    validate_val "Buffer content:   " "$(commandline)" "$_buffer"
    validate_val "Selection content:" "$(commandline --current-selection)" "$_selection"
    echo $result >> "$out"
    exit
end

set -g fish_key_bindings fish_helix_key_bindings
bind --user --erase --all
for mode in default visual insert
    # \e\e must correspond to tmux key sequence in tests/_run.fish
    bind --user -M $mode \e\e validate
end

