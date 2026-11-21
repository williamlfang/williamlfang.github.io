#!/usr/bin/env bash
# Called by the local zsh ssh() wrapper. Probe only interactive SSH logins;
# remote commands, tunnels and unusual invocations retain ordinary SSH behavior.
# No remote files are changed. A read-only observer tracks active remote tmux
# clients: Ctrl-j alone keeps Ctrl-k local; foreground ssh forwards to the next
# hop. Failed/ambiguous detection stays local. Ctrl-b F12 overrides until the
# route changes. Restore the pane's previous setting when the login exits.
probe=1
host_seen=0
expect_value=0
end_options=0
for arg in "$@"; do
    if (( expect_value )); then
        expect_value=0
        continue
    fi
    if (( ! end_options )); then
        case "$arg" in
            --) end_options=1; continue ;;
            -*)
                # Walk clustered short options, including attached values (-p62222).
                flags=${arg#-}
                while [[ -n $flags ]]; do
                    flag=${flags:0:1}
                    flags=${flags:1}
                    case "$flag" in
                        # Noninteractive modes must not trigger a probe.
                        f|G|N|n|O|Q|s|T|V|W) probe=0 ;;
                    esac
                    case "$flag" in
                        B|b|c|D|E|e|F|I|i|J|L|l|m|O|o|P|p|Q|R|S|W|w)
                            [[ -n $flags ]] || expect_value=1
                            break ;;
                        4|6|A|a|C|f|G|g|K|k|M|N|n|q|s|T|t|V|v|X|x|Y|y) ;;
                        *) probe=0 ;;
                    esac
                done
                continue ;;
        esac
    fi
    if (( host_seen )); then
        # A remote command was supplied. Do not run it twice or alter its keys.
        probe=0
    fi
    host_seen=1
done

if [[ -n ${TMUX:-} && -n ${TMUX_PANE:-} ]] &&
    (( probe && host_seen && ! expect_value )); then
    previous=$(command tmux show-options -pqv -t "$TMUX_PANE" @remote_ctrl_k 2>/dev/null)
    watcher=
    restore_prefix() {
        if [[ -n $watcher ]]; then
            kill "$watcher" 2>/dev/null
            wait "$watcher" 2>/dev/null
        fi
        if [[ -n $previous ]]; then
            command tmux set-option -p -t "$TMUX_PANE" @remote_ctrl_k "$previous" 2>/dev/null
        else
            command tmux set-option -pu -t "$TMUX_PANE" @remote_ctrl_k 2>/dev/null
        fi
    }
    trap restore_prefix EXIT
    command tmux set-option -p -t "$TMUX_PANE" @remote_ctrl_k 0
    command python3 "$HOME/.tmux/scripts/ssh-prefix-watch.py" "$TMUX_PANE" "$@" \
        </dev/null >/dev/null 2>&1 &
    watcher=$!
fi

command ssh "$@"
exit $?
