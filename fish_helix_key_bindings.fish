# IMPORTANT!!!
#
# When defining your own bindings using fish_helix_commandline, be aware that it can break
# stuff sometimes.
#
# It is safe to define a binding consisting of a lone call to fish_helix_commandline.
# Calls to other functions and executables are allowed along with it, granted they don't mess
# with fish's commandline buffer.
#
# Mixing multiple fish_helix_commandline and commandline calls in one binding MAY trigger issues.
# Nothing serious, but don't be surprised. Just test it.

function fish_helix_key_bindings --description 'helix-like key bindings for fish'
    if contains -- -h $argv
        or contains -- --help $argv
        echo "Sorry but this function doesn't support -h or --help"
        return 1
    end

    # Erase all bindings if not explicitly requested otherwise to
    # allow for hybrid bindings.
    # This needs to be checked here because if we are called again
    # via the variable handler the argument will be gone.
    set -l rebind true
    if test "$argv[1]" = --no-erase
        set rebind false
        set -e argv[1]
    else
        bind --erase --all --preset # clear earlier bindings, if any
    end

    # Allow just calling this function to correctly set the bindings.
    # Because it's a rather discoverable name, users will execute it
    # and without this would then have subtly broken bindings.
    if test "$fish_key_bindings" != fish_helix_key_bindings
        and test "$rebind" = true
        # Allow the user to set the variable universally.
        set -q fish_key_bindings
        or set -g fish_key_bindings
        # This triggers the handler, which calls us again and ensures the user_key_bindings
        # are executed.
        set fish_key_bindings fish_helix_key_bindings
        return
    end

    set -l init_mode insert

    if contains -- $argv[1] insert default visual
        set init_mode $argv[1]
    else if set -q argv[1]
        # We should still go on so the bindings still get set.
        echo "Unknown argument $argv" >&2
    end

    # Inherit shared key bindings.
    # Do this first so helix-bindings win over default.
    for mode in insert default visual
        __fish_shared_key_bindings -s -M $mode
    end

    bind -s --preset -M insert \r execute
    bind -s --preset -M insert \n execute

    bind -s --preset -M insert "" self-insert

    # Space and other command terminators expand abbrs _and_ inserts itself.
    bind -s --preset -M insert " " self-insert expand-abbr
    bind -s --preset -M insert ";" self-insert expand-abbr
    bind -s --preset -M insert "|" self-insert expand-abbr
    bind -s --preset -M insert "&" self-insert expand-abbr
    bind -s --preset -M insert "^" self-insert expand-abbr
    bind -s --preset -M insert ">" self-insert expand-abbr
    bind -s --preset -M insert "<" self-insert expand-abbr
    # Closing a command substitution expands abbreviations
    bind -s --preset -M insert ")" self-insert expand-abbr
    # Ctrl-space inserts space without expanding abbrs
    bind -s --preset -M insert -k nul 'commandline -i " "'

    # Switching to insert mode
    for mode in default visual
        bind -s --preset -M $mode -m insert \cc end-selection cancel-commandline repaint-mode
        bind -s --preset -M $mode -m insert \n end-selection execute
        bind -s --preset -M $mode -m insert \r end-selection execute
        bind -s --preset -M $mode -m insert o end-selection insert-line-under repaint-mode
        bind -s --preset -M $mode -m insert O end-selection insert-line-over repaint-mode
        # FIXME handle selection properly for the following commands (at the command, and during editing):
        bind -s --preset -M $mode -m insert i end-selection repaint-mode
        bind -s --preset -M $mode -m insert I end-selection beginning-of-line repaint-mode
        bind -s --preset -M $mode -m insert a end-selection forward-single-char repaint-mode
        bind -s --preset -M $mode -m insert A end-selection end-of-line repaint-mode
    end

    # Switching from insert mode
    # Note if we are paging, we want to stay in insert mode
    # See #2871
    bind -s --preset -M insert \e "if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f begin-selection repaint-mode; end"

    # Switching between normal and visual mode
    bind -s --preset -M default -m visual v repaint-mode
    for key in v \e
        bind -s --preset -M visual -m default $key repaint-mode
    end


    # Motion and actions in normal/select mode
    for mode in default visual
        if test $mode = default
            set -f n_begin_selection "begin-selection" # only begin-selection if current mode is Normal
            set -f ns_move_extend "move"
        else
            set -f n_begin_selection
            set -f ns_move_extend "extend"
        end

        for key in (seq 0 9)
            bind -s --preset -M $mode $key "fish_bind_count $key"
            # FIXME example to bind 0
            # FIXME backspace to edit count
        end
        for key in h \e\[D \eOD "-k left"
            bind -s --preset -M $mode $key "fish_helix_command "$ns_move_extend"_char_left"
        end
        for key in l \e\[C \eOC "-k right"
            bind -s --preset -M $mode $key "fish_helix_command "$ns_move_extend"_char_right"
        end
        bind -s --preset -M $mode w "fish_helix_command "$ns_move_extend"_next_word_start"
        bind -s --preset -M $mode b "fish_helix_command "$ns_move_extend"_prev_word_start"
        bind -s --preset -M $mode e "fish_helix_command "$ns_move_extend"_next_word_end"
        bind -s --preset -M $mode W "fish_helix_command "$ns_move_extend"_next_long_word_start"
        bind -s --preset -M $mode B "fish_helix_command "$ns_move_extend"_prev_long_word_start"
        bind -s --preset -M $mode E "fish_helix_command "$ns_move_extend"_next_long_word_end"

        bind -s --preset -M $mode gh beginning-of-line $n_begin_selection
        bind -s --preset -M $mode gl end-of-line $n_begin_selection
        bind -s --preset -M $mode gg beginning-of-buffer $n_begin_selection # this can accept count before and between `g`'s
        bind -s --preset -M $mode ge end-of-buffer beginning-of-line $n_begin_selection
        # FIXME home/end

        bind -s --preset -M $mode u undo begin-selection
        bind -s --preset -M $mode U redo begin-selection


        bind -s --preset -M $mode f $n_begin_selection forward-jump
        bind -s --preset -M $mode F $n_begin_selection backward-jump
        bind -s --preset -M $mode t $n_begin_selection forward-single-char forward-jump-till
        bind -s --preset -M $mode T $n_begin_selection backward-char backward-jump-till
        # FIXME alt-. doesn't work with t/T
        bind -s --preset -M $mode \e. repeat-jump

        bind -s --preset -M $mode -m replace_one r repaint-mode

        # FIXME !
        # FIXME registers
        # FIXME selection and cursor behavior
        bind -s --preset -M $mode y fish_clipboard_copy
        bind -s --preset -M $mode P fish_clipboard_paste
        bind -s --preset -M $mode p "commandline -f forward-single-char begin-selection ; fish_clipboard_paste"
        bind -s --preset -M $mode Q yank-pop
        bind -s --preset -M $mode R kill-selection begin-selection yank-pop yank

        # FIXME keep selection
        bind -s --preset -M $mode ~ togglecase-selection
        # FIXME ` and \e`

        # FIXME .
        # FIXME < and >
        # FIXME =

        bind -s --preset -M $mode -m default d kill-selection begin-selection $v_repaint_mode
        bind -s --preset -M $mode -m insert c kill-selection end-selection repaint-mode
        # FIXME \ed \ec

        # FIXME \ca \cx
        # FIXME Qq

        ## Shell
        # FIXME

        ## Selection manipulation
        # FIXME & _

        bind -s --preset -M $mode \; begin-selection
        bind -s --preset -M $mode \e\; swap-selection-start-stop
        # FIXME \e:
        # FIXME %
        # FIXME x X \ex
        # FIXME J
        # FIXME \cc

        ## Search
        # FIXME

        ## FIXME minor modes: g, m, space

        ## FIXME [ and ] motions
    end

    # FIXME should replace the whole selection
    # FIXME should be able to go back to visual mode
    bind -s --preset -M replace_one -m default '' delete-char self-insert backward-char repaint-mode
    bind -s --preset -M replace_one -m default \r 'commandline -f delete-char; commandline -i \n; commandline -f backward-char; commandline -f repaint-mode'
    bind -s --preset -M replace_one -m default \e cancel repaint-mode

    bind -s --preset -M default k up-or-search
    bind -s --preset -M default j down-or-search
    bind -s --preset -M visual k up-line
    bind -s --preset -M visual j down-line
    # FIXME arrows

    ## FIXME Insert mode keys

    ## Old config from vi:

    # Vi moves the cursor back if, after deleting, it is at EOL.
    # To emulate that, move forward, then backward, which will be a NOP
    # if there is something to move forward to.
    bind -s --preset -M insert -k dc delete-char forward-single-char backward-char
    bind -s --preset -M default -k dc delete-char forward-single-char backward-char

    # Backspace deletes a char in insert mode, but not in normal/default mode.
    bind -s --preset -M insert -k backspace backward-delete-char
    bind -s --preset -M default -k backspace backward-char
    bind -s --preset -M insert \ch backward-delete-char
    bind -s --preset -M default \ch backward-char
    bind -s --preset -M insert \x7f backward-delete-char
    bind -s --preset -M default \x7f backward-char
    bind -s --preset -M insert -k sdc backward-delete-char # shifted delete
    bind -s --preset -M default -k sdc backward-delete-char # shifted delete


#    bind -s --preset '~' togglecase-char forward-single-char
#    bind -s --preset gu downcase-word
#    bind -s --preset gU upcase-word
#
#    bind -s --preset J end-of-line delete-char
#    bind -s --preset K 'man (commandline -t) 2>/dev/null; or echo -n \a'
#



    # same vim 'pasting' note as upper
    bind -s --preset '"*p' forward-char "commandline -i ( xsel -p; echo )[1]"
    bind -s --preset '"*P' "commandline -i ( xsel -p; echo )[1]"



    #
    # visual mode
    #



    # bind -s --preset -M visual -m insert c kill-selection end-selection repaint-mode
    # bind -s --preset -M visual -m insert s kill-selection end-selection repaint-mode
    bind -s --preset -M visual -m default '"*y' "fish_clipboard_copy; commandline -f end-selection repaint-mode"
    bind -s --preset -M visual -m default '~' togglecase-selection end-selection repaint-mode



    # Set the cursor shape
    # After executing once, this will have defined functions listening for the variable.
    # Therefore it needs to be before setting fish_bind_mode.
    # fish_vi_cursor

    set fish_bind_mode $init_mode

end
