#!/usr/bin/env bash
# Called by the local zsh ssh() wrapper. Only interactive logins change routing.
# Substitute your real hostname and ports below; 192.0.2.82 is an example.
probe=1
destination=
port=
expect_value=
end_options=0
for arg in "$@"; do
    if [[ -n $expect_value ]]; then
        [[ $expect_value != p ]] || port=$arg
        expect_value=
        continue
    fi
    if (( ! end_options )); then
        case "$arg" in
            --) end_options=1; continue ;;
            -*)
                flags=${arg#-}
                while [[ -n $flags ]]; do
                    flag=${flags:0:1}
                    flags=${flags:1}
                    case "$flag" in
                        f|G|N|n|O|Q|s|T|V|W) probe=0 ;;
                    esac
                    case "$flag" in
                        B|b|c|D|E|e|F|I|i|J|L|l|m|O|o|P|p|Q|R|S|W|w)
                            if [[ -z $flags ]]; then
                                expect_value=$flag
                            elif [[ $flag == p ]]; then
                                port=$flags
                            fi
                            break ;;
                        4|6|A|a|C|f|G|g|K|k|M|N|n|q|s|T|t|V|v|X|x|Y|y) ;;
                        *) probe=0 ;;
                    esac
                done
                continue ;;
        esac
    fi
    if [[ -n $destination ]]; then
        probe=0  # Remote command: leave routing alone.
    else
        destination=$arg
    fi
done

if [[ -n ${TMUX:-} && -n ${TMUX_PANE:-} && -n $destination && -z $expect_value ]] &&
    (( probe )); then
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
    if [[ ( $destination == william@127.0.0.1 && $port == 62222 ) ||
          ( $destination == william@192.0.2.82 && ( $port == 62222 || $port == 62223 ) ) ]]; then
        # Known forwarded endpoint: enable Ctrl-k before SSH starts.
        command tmux set-option -p -t "$TMUX_PANE" @remote_ctrl_k 1
    else
        # Other first hops need to detect a foreground second SSH dynamically.
        command tmux set-option -p -t "$TMUX_PANE" @remote_ctrl_k 0
        command python3 "$HOME/.tmux/scripts/ssh-prefix-watch.py" "$TMUX_PANE" "$@" \
            </dev/null >/dev/null 2>&1 &
        watcher=$!
    fi
fi

command ssh "$@"
exit $?
