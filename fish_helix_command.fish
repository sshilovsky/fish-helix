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
                __fish_helix_next_word_start (string replace -r '_.*' '' $command) $count '[:space:]' '[:alnum:]_'
            case {move,extend}_next_long_word_start
                __fish_helix_next_word_start (string replace -r '_.*' '' $command) $count '[:space:]'

            case '*'
                echo "[fish-helix]" Unknown command $command >&2
        end
    end
end

function __fish_helix_char_category -a char
    set -f patterns $argv[2..-1]
    for index in (seq 1 (count $patterns))
        if test "$char" = \n
            echo N
            return
        end
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
    set -f cursor (math (commandline -C) + 1) # convert to `cut` format
    set -f char1
    set -f char2
    set -f category1
    set -f category2
    set -f begin_selection
    for i in (seq 1 $count)
        # skip starting newlines
        while test "$(echo "$buffer" | cut -zc(math $cursor + 1))" = \n
            set cursor (math $cursor + 1)
        end

        set begin_selection $cursor

        set -l first yes
        while true
            set -l pair "$(echo "$buffer" | cut -zc$cursor,(math $cursor + 1))"
            set char1 "$(echo "$pair" | cut -zc1)"
            set char2 "$(echo "$pair" | cut -zc2)"
            test "$char2" = ""; and break

            set category1 (__fish_helix_char_category "$char1" $patterns)
            set category2 (__fish_helix_char_category "$char2" $patterns)

            if test $category1 != $category2 -a $category2 != 1
                if test -n $first
                    set begin_selection (math $cursor + 1)
                else
                    break
                end
            end
            set cursor (math $cursor + 1)
            set first ""
        end
    end

    if test $mode = move
        commandline -C (math $begin_selection - 1)
        commandline -f begin-selection
        for j in (seq $begin_selection (math $cursor - 1))
            commandline -f forward-char
        end
    else
        commandline -C (math $cursor - 1)
    end
end
