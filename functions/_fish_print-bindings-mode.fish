function _fish_print-bindings-mode --argument-names={color,letter} --description='Print the editor mode in bold with dimmed `[]`'
    set_color --bold --dim {$color}
    echo -n \[

    set_color normal
    set_color --bold $color
    echo -n {$letter}

    set_color --bold --dim {$color}
    echo \]
end
