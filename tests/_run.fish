# TODO error handling
set -l test_file "$argv[1]"
set -l temp_dir "$argv[2]"
set -l root "$(dirname "$(status filename)")"
set -l tmux tmux -f /dev/null -S "$temp_dir/tmux"

truncate --size 0 "$temp_dir/out"
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
read -l subprocess_pid tmux_pane < $temp_dir/fifo

source $test_file

# FIXME maybe more reliable wait+kill
fish -c "sleep 0.5; kill $subprocess_pid --timeout 500 SIGKILL" &
set -l killer_pid $last_pid
fish -c "wait $subprocess_pid" 2>/dev/null
kill $killer_pid

sync "$temp_dir/out" ; sleep 0.3 # can't sync without sleep :(

read -l result < "$temp_dir/status"
if test "$result" = passed
    exit 0
end
if test -n "$_broken"
    echo "Test $test_file is broken" >&2
    exit 2
else
    echo "Test $test_file has failed" >&2
    cat "$temp_dir/out" >&2
    exit 1
end
