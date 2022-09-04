
set -l root $(dirname $(status filename))

# TODO error handling
set -l test_file $argv[1]
set -l test_fifo $argv[2]
set -l test_out $argv[3]

truncate --size 0 "$test_out"
# TODO path to compiled fish executable
tmux -f /dev/null new-session -d fish -i -C \
    "source $root/_init.fish $test_fifo $test_out; source $test_file"

read -l subprocess_pid tmux_pane < $test_fifo

source $test_file
# Escape Escape must correspond to the binding in tests/_init.fish
tmux -f /dev/null send-keys -t "$tmux_pane" $_input Escape Escape

# FIXME maybe more reliable wait+kill
fish -c "sleep 0.5; kill $subprocess_pid --timeout 500 SIGKILL" &
set -l killer_pid $last_pid
fish -c "wait $subprocess_pid" 2>/dev/null
kill $killer_pid

sync "$test_out"
set -l last_line (tail -n1 "$test_out")
if test "$last_line" != "ok"
    echo "Test $test_file has failed"
    head -n-1 "$test_out"
    return 1
end >&2