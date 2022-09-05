
set -l root "$(dirname "$(status filename)")"

# TODO error handling
set -l test_file "$argv[1]"
set -l test_fifo "$argv[2]"
set -l test_out "$argv[3]"

truncate --size 0 "$test_out"
# TODO path to compiled fish executable
tmux -f /dev/null new-session -d fish --private -i -C \
    "source $root/_init.fish $test_fifo $test_out; source $test_file"

# TODO may hang up if session dies immediately. maybe use separate tmux socket, and check on it
read -l subprocess_pid tmux_pane < $test_fifo

source $test_file
for sequence in $_input
    if test "$sequence" = "Normal"
        tmux -f /dev/null send-keys -t "$tmux_pane" F11
    else
        tmux -f /dev/null send-keys -t "$tmux_pane" $sequence
    end
end
tmux -f /dev/null send-keys -t "$tmux_pane" F12
 

# FIXME maybe more reliable wait+kill
fish -c "sleep 0.5; kill $subprocess_pid --timeout 500 SIGKILL" &
set -l killer_pid $last_pid
fish -c "wait $subprocess_pid" 2>/dev/null
kill $killer_pid

sync "$test_out" ; sleep 0.1 # can't sync without sleep :(
set -l last_line "$(tail -n1 "$test_out")"
if test "$last_line" != "ok"
    echo "Test $test_file has failed" >&2
    head -n-1 "$test_out" >&2
    exit 1
end >&2