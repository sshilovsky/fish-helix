# TODO error handling
set -l test_file "$argv[1]"
set -l temp_dir "$argv[2]"
set -l root "$(dirname "$(status filename)")"

mkdir -p "$temp_dir/result"
# TODO path to compiled fish executable
tmux -f /dev/null -S "$temp_dir/tmux" new-session -dPF "#{session_name}" \
    fish --private -i -C "\
        source $root/../functions/fish_bind_count.fish; \
        source $root/../functions/fish_helix_command.fish; \
        source $root/../functions/fish_default_mode_prompt.fish; \
        source $root/../functions/fish_helix_key_bindings.fish; \
        source $root/_init.fish $temp_dir; \
        source $test_file; \
        source $root/_done.fish; \
    " | read -l tmux_session

inotifywait -t 1 -e close_write "$temp_dir/result" >/dev/null 2>&1
tmux kill-session -t "$tmux_session" 2>/dev/null

test ! -e "$temp_dir/fixed" -a ! -e "$temp_dir/failure"
