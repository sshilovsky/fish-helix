# Initialization file for the tests

# TODO error handling

set temp_dir "$argv[1]"
set tmux tmux -f /dev/null

function validate
    touch "$temp_dir/result/result"
    exit
end

set check_index 0

function check
    set check_index (math $check_index + 1)
    set property "$q_property[$check_index]"
    set broken $q_broken[$check_index]
    set expected "$q_expected[$check_index]"
    test -n "$broken" && touch "$temp_dir/broken"
    switch $property
    case mode
        set caption "Bind mode:        "
        set value "$fish_bind_mode"
    case line
        set caption "Cursor line:      "
        set value "$(commandline --line)"
    case cursor
        set caption "Cursor position:  "
        set value "$(commandline --cursor)"
    case buffer
        set caption "Buffer content:   "
        commandline | sed -z 's/\\n$//' | read -lz buffer
        set value "$buffer"
    case selection
        set caption "Selection content:"
        commandline --current-selection | sed -z 's/\\n$//' | read -lz selection
        set value "$selection"
    end
    if test _"$value" != _"$expected"
        echo "$caption $(string escape -- "$value") ($(string escape -- "$expected") expected)" >> "$temp_dir/out"
        test -z $broken && touch "$temp_dir/failure"
    else if test -n $broken
        echo "$caption $(string escape -- "$value") (broken value fixed)" >> "$temp_dir/out"
        touch "$temp_dir/fixed"
    else
        echo "$caption $(string escape -- "$value")" >> "$temp_dir/out"
    end
end

set q_property
set q_broken
set q_expected

function push_check -a property
    set expected $argv[2..-1]
    set broken ""
    if test _"$expected[1]" = _--broken
        set broken yes
        set expected $expected[2..-1]
    end
    set -a q_property "$property"
    set -a q_broken "$broken"
    set -a q_expected "$expected"
    $tmux send-keys F9
end

function _mode
    push_check mode $argv
end

function _line
    push_check line $argv
end

function _cursor
    push_check cursor $argv
end

function _buffer
    push_check buffer $argv
end

function _selection
    push_check selection $argv
end

function _input
    for sequence in $argv
        switch "$sequence"
        case "Normal"
            $tmux send-keys F11
        case "Line"
            $tmux send-keys F11 o
        case '*'
            $tmux send-keys -- "$sequence"
        end
    end
end

set -g fish_key_bindings fish_helix_key_bindings
bind --user --erase --all
for mode in default visual insert
    bind --user -M $mode -k f12 validate
    bind --user -M $mode -k f9 check
end
bind --user -M insert -m default -k f11 ''
