# TODO error handling
set -l test_file "$argv[1]"
set -l temp_dir "$argv[2]"
set -l root "$(dirname "$(status filename)")"
set -l tmux tmux -f /dev/null -S "$temp_dir/tmux"

mkdir -p "$temp_dir/status"
# TODO path to compiled fish executable
$tmux new-session -d fish --private -i -C "\
    source $root/../fish_bind_count.fish; \
    source $root/../fish_helix_command.fish; \
    source $root/../fish_default_mode_prompt.fish; \
    source $root/../fish_helix_key_bindings.fish; \
    source $test_file; \
    source $root/_init.fish $temp_dir; \
"

# TODO may hang up if session dies immediately. maybe use separate tmux socket, and check on it
# alternatively, tmux new-session -P may tell session id
read -l subprocess_pid tmux_pane < "$temp_dir"/fifo

if not inotifywait -t 1 -e create "$temp_dir/status" >/dev/null 2>&1
    # timeout, probably
end
read -l result < "$temp_dir/status/status"

switch "$result"
case passed
    exit 0
case broken
    echo "Test $test_file is broken" >&2
    exit 2
case failed
    echo "Test $test_file has failed" >&2
    cat "$temp_dir/out" >&2
    exit 1
case *
    echo "Test $test_file hasn't completed" >&2
    exit 1
end
