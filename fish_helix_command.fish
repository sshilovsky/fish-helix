function fish_helix_command
    argparse 'h/help' -- $argv
    or return 1
    if test -n "$_flag_help"
        echo "Helper function to handle modal key bindings mostly outside of insert mode"
        return
    end
    
    for command in $argv
        set -f count (fish_bind_count -r)

        switch $command
            case move_char_left
                commandline -C (math max\(0, (commandline -C) - $count\))
                commandline -f begin-selection
            case extend_char_left
                commandline -C (math max\(0, (commandline -C) - $count\))
            case move_char_right
                commandline -C (math (commandline -C) + $count)
                commandline -f begin-selection
            case extend_char_right
                commandline -C (math (commandline -C) + $count)

            case {move,extend}_next_word_start
                __fish_helix_next_word_start (string replace -r '_.*' '' $command) $count '[:space:]' '\n' '[:alnum:]_'
            case {move,extend}_next_long_word_start
                __fish_helix_next_word_start (string replace -r '_.*' '' $command) $count '[:space:]' '\n'
            
            case '*'
                echo "[fish-helix]" Unknown command $command >&2
        end
    end
end

function __fish_helix_char_category -a char
    set -f patterns $argv[2..-1]
    for index in (seq 1 (count $patterns))
        if test -z "$(echo "$char" | tr -d "$patterns[$index]")"
            echo $index
            return
        end
    end
    echo 0
end
function __fish_helix_next_word_start -a mode count
    set -f patterns $argv[3..-1]
    set -f buffer "$(commandline)"
    set -f char1
    set -f char2
    set -f category1
    set -f category2
    # echo $mode $count
    # echo (string escape $patterns)
    for i in (seq 1 $count)
        # test $mode = move; and commandline -f begin-selection
        # skip starting newlines
        while test "$(string sub -s (math (commandline -C) + 1) -l 1 "$buffer")" = \n
            commandline -C (math (commandline -C) + 1)
        end

        commandline -C (math (commandline -C) + 1)
        while true
            set -l pair "$(string sub -s (math (commandline -C) + 1) -l 2 "$buffer")"
            set char1 "$(string sub -l 1 "$pair")"
            set char2 "$(string sub -s 2 -l 1 "$pair")"
            test "$char2" = ""; and return
            set category1 (__fish_helix_char_category "$char1" $patterns)
            set category2 (__fish_helix_char_category "$char2" $patterns)
            if test $category1 != $category2 -a $category2 != 1
                break
            end
            commandline -C (math (commandline -C) + 1) # TODO replace with call to extend_char_right(count=1)
        end
    end
end