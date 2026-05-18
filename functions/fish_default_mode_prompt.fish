function fish_default_mode_prompt --description "Display vi/helix prompt mode"
    # Do nothing if not in vi mode
    if test "$fish_key_bindings" = fish_vi_key_bindings
        or test "$fish_key_bindings" = fish_helix_key_bindings
        or test "$fish_key_bindings" = fish_hybrid_key_bindings
        switch $fish_bind_mode
            case default
                _fish_print-bindings-mode red N
            case insert
                _fish_print-bindings-mode green I
            case replace_one
                _fish_print-bindings-mode green R
            case replace
                _fish_print-bindings-mode cyan R
            case visual
                _fish_print-bindings-mode magenta V
        end
        set_color normal
        echo -n ' '
    end
end
