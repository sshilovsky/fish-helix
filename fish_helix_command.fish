function fish_helix_command
    argparse 'h/help' -- $argv
    or return 1
    if test -n "$_flag_help"
        echo "Helper function to handle modal key bindings mostly outside of insert mode"
        return
    end
    
    for command in $argv
        set -f count (fish_bind_count -r)

        switch "$command"
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
            
            case '*'
                echo "[fish-helix]" Unknown command "$command" >&2
        end
    end
end

