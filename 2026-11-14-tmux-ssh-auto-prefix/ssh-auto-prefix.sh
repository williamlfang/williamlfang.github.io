#!/usr/bin/env bash
# Called by the local zsh ssh() wrapper. Probe only interactive SSH logins;
# remote commands, tunnels and unusual invocations retain ordinary SSH behavior.
# No remote files are changed. A failed/ambiguous probe leaves Ctrl-k local.

forward=0
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
    # Options are placed first because OpenSSH uses the first obtained value.
    # Reuse SSH config/identity/ProxyJump, but never prompt during the probe,
    # start forwards, run LocalCommand/RemoteCommand, or allocate a terminal.
    prefixes=$(command ssh \
        -o BatchMode=yes -o ConnectTimeout=4 -o ConnectionAttempts=1 \
        -o ClearAllForwardings=yes -o PermitLocalCommand=no \
        -o RemoteCommand=none -o RequestTTY=no -o ControlMaster=no \
        "$@" "tmux list-sessions -F '#{prefix} #{prefix2}' 2>/dev/null" \
        2>/dev/null) || prefixes=

    # Only forward when every running session on the default remote tmux
    # socket accepts Ctrl-k. Mixed prefixes are ambiguous: stay local.
    if [[ -n $prefixes ]]; then
        forward=1
        while IFS= read -r line; do
            case " $line " in
                *' C-k '*) ;;
                *) forward=0; break ;;
            esac
        done <<< "$prefixes"
    fi
fi

if [[ -n ${TMUX:-} && -n ${TMUX_PANE:-} ]] &&
    (( probe && host_seen && ! expect_value )); then
    previous=$(command tmux show-options -pqv -t "$TMUX_PANE" @remote_ctrl_k 2>/dev/null)
    restore_prefix() {
        if [[ -n $previous ]]; then
            command tmux set-option -p -t "$TMUX_PANE" @remote_ctrl_k "$previous" 2>/dev/null
        else
            command tmux set-option -pu -t "$TMUX_PANE" @remote_ctrl_k 2>/dev/null
        fi
    }
    trap restore_prefix EXIT
    command tmux set-option -p -t "$TMUX_PANE" @remote_ctrl_k "$forward"
    if (( forward )); then
        printf '%s\n' '[tmux] Remote uses Ctrl-k: forwarding Ctrl-k; Ctrl-b controls local tmux.' >&2
    fi
fi

command ssh "$@"
exit $?
