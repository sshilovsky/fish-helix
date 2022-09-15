# FIXME this can't be called in sequence in general case,
# because of unsynchronized `commandline -f` and `commandline -C`

function fish_helix_command
    argparse 'h/help' -- $argv
    or return 1
    if test -n "$_flag_help"
        echo "Helper function to handle modal key bindings mostly outside of insert mode"
        return
    end

    # TODO only single command allowed really yet,
    #     because `commandline -f` queues actions, while `commandline -C` is immediate
    for command in $argv
        set -f count (fish_bind_count -r)
        set -f count_defined $status

        switch $command
        case {move,extend}_char_left
            commandline -C (math max\(0, (commandline -C) - $count\))
            __fish_helix_extend_by_command $command
        case {move,extend}_char_right
            commandline -C (math (commandline -C) + $count)
            __fish_helix_extend_by_command $command

        case {move,extend}_{next,prev}_{long_,}word_{start,end}
            if string match -qr _long_ $command
                set -f longword
            else
                set -f longword '[[:alnum:]_]'
            end
            if string match -qr _next_ $command
                set -f dir "1"
            else
                set -f dir "-1"
            end
            __fish_helix_word_motion (string split : (string replace -r '_.*_' : $command)) \
                $dir $count '[[:space:]]' $longword

        case till_next_char
            __fish_helix_find_char $fish_bind_mode $count forward-jump-till forward-char
        case find_next_char
            __fish_helix_find_char $fish_bind_mode $count forward-jump
        case till_prev_char
            __fish_helix_find_char $fish_bind_mode $count backward-jump-till backward-char
        case find_prev_char
            __fish_helix_find_char $fish_bind_mode $count backward-jump

        case till_next_cr
            __fish_helix_find_next_cr $fish_bind_mode $count 2
        case find_next_cr
            __fish_helix_find_next_cr $fish_bind_mode $count 1
        case till_prev_cr
            __fish_helix_find_prev_cr $fish_bind_mode $count 1
        case find_prev_cr
            __fish_helix_find_prev_cr $fish_bind_mode $count 0

        case goto_line_start
            commandline -f beginning-of-line
            __fish_helix_extend_by_mode
        case goto_line_end
            goto_line_end
            __fish_helix_extend_by_mode
        case goto_first_nonwhitespace
            goto_first_nonwhitespace
            __fish_helix_extend_by_mode

        case goto_file_start
            goto_line $count
        case goto_line
            if test "$count_defined" = 0 # if true
                goto_line $count
            end
        case goto_last_line
            commandline -f end-of-buffer beginning-of-line
            __fish_helix_extend_by_mode


        case '*'
            echo "[fish-helix]" Unknown command $command >&2
        end
    end
end

function __fish_helix_extend_by_command -a piece
    if not string match -qr extend_ $piece
        commandline -f begin-selection
    end
end

function __fish_helix_extend_by_mode
    if test $fish_bind_mode = default
        commandline -f begin-selection
    end
end

function __fish_helix_char_category -a char
    set -f patterns $argv[2..-1]
    for index in (seq 1 (count $patterns))
        if test _"$char" = _\n
            echo N
            return
        end
        # echo -- (string escape -- "$char") "$patterns[$index]" > /dev/stdout
        echo -- "$char" | grep -q -- "$patterns[$index]"
        if test $status = 0
            # echo result=$index > /dev/stdout
            echo $index
            return
        end
    end
    echo 0
    # echo result=0 > /dev/stdout
end

function __fish_helix_word_motion -a mode side dir count
    set -f patterns $argv[5..-1]
    commandline | sed -z 's/\\n$//' | read -fz buffer
    set -f cursor (commandline -C)
    set -f char1
    set -f char2
    set -f category1
    set -f category2
    set -f begin_selection
    for i in (seq 1 $count)
        # skip starting newlines
        while begin
            set -l pos (math $cursor + $dir)
            test $pos -ge 0 && string match -qr '^.{'$pos'}'\n -- "$buffer"
        end
            set cursor (math $cursor + $dir)
        end

        set begin_selection $cursor

        set -l first yes
        while true
            test $cursor = 0 -a $dir = "-1"; and break
            set char1 "$(echo -- "$buffer" | sed -z 's/.\{'$cursor'\}\(.\).*/\1/')"
            set char2 "$(echo -- "$buffer" | sed -z 's/.\{'(math $cursor + $dir)'\}\(.\).*/\1/')"
            test _"$char2" = _; and break

            set category1 (__fish_helix_char_category "$char1" $patterns)
            set category2 (__fish_helix_char_category "$char2" $patterns)

            if test \( $side = start -a $dir = 1 \) -o \( $side = end -a $dir = -1 \)
                set -f my_cat $category2
            else
                set -f my_cat $category1
            end
            # echo "[$first]" (string escape -- "$char1$char2") $category1 $category2 $my_cat
            if test $category1 != $category2 -a $my_cat != 1
                if test -n $first
                    set begin_selection (math $cursor + $dir)
                else
                    break
                end
            end
            set cursor (math $cursor + $dir)
            set first ""
        end
    end

    if test $mode = move
        # echo $begin_selection $cursor
        commandline -C $begin_selection
        commandline -f begin-selection

        for j in (seq $begin_selection (math $cursor - 1))
            commandline -f forward-char
        end
        for j in (seq $begin_selection -1 (math $cursor + 1))
            commandline -f backward-char
        end
    else
        commandline -C $cursor
    end
end

function __fish_helix_find_char -a mode count fish_cmdline till
    # FIXME don't reset selection if N/A
    if test $mode = default
        commandline -f begin-selection
    end
    commandline -f $till $fish_cmdline
    for i in (seq 2 $count)
        commandline -f $till repeat-jump
    end
end

function __fish_helix_find_next_cr -a mode count skip
    set -l cursor (commandline -C)
    commandline | # Include endling newline intentionally
    # Skip until cursor:
    sed -z 's/^.\{'(math $cursor + $skip)'\}\(.*\)$/\\1/' |
    # Count characters up to the target newline:
    sed -z 's/^\(\([^\\n]*\\n\)\{0,'$count'\}\).*/\\1/' |
    read -zl chars

    if test $mode = default -a -n "$chars"
        commandline -f begin-selection
    end
    for i in (seq 1 (string length -- "$chars"))
        commandline -f forward-char
    end
end

function __fish_helix_find_prev_cr -a mode count skip
    set -l cursor (commandline -C)
    commandline --cut-at-cursor |
    sed -z 's/.\{'$skip'\}\n$//' |
    read -zl buffer

    echo -n $buffer |
    # Drop characters up to the target newline:
    sed -z 's/\(\(\\n[^\\n]*\)\{0,'$count'\}\)$//' |
    read -zl chars
    set -l n_chars (math (string length -- "$buffer") - (string length -- "$chars"))

    if test $mode = default -a $n_chars != 0
        commandline -f begin-selection
    end
    for i in (seq 1 $n_chars)
        commandline -f backward-char
    end
end

function goto_line_end
    # check if we are on an empty line first
    commandline | sed -n (commandline -L)'!b;/^$/q;q5' && return
    commandline -f end-of-line backward-char
end

function goto_first_nonwhitespace
    # check if we are on whitespace line first
    commandline | sed -n (commandline -L)'!b;/^\\s*$/q;q5' && return
    commandline -f beginning-of-line forward-bigword backward-bigword
end

function goto_line -a number
    set -l lines (math min\($number, (commandline | wc -l)\))
    commandline -f beginning-of-buffer
    for i in (seq 2 $lines)
        commandline -f down-line
    end
    __fish_helix_extend_by_mode
end
