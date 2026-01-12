#!/usr/bin/env bash

export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-$(dbus-launch)}"
HYPR_SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

handle() {
    case $1 in
        workspacev2*)
            current="${1: -1}"
            #total="$(hyprctl workspaces | grep -v "workspace ID -" | grep -c "^workspace ID")"
            #total="$(hyprctl workspaces | grep "ID" | tail -n 2 | head -n 1 | awk '{print $3}')"
            makoctl dismiss -a
            notify-send "Workspace $current" -t 500
            #windows="$(hyprctl activeworkspace | grep "windows: " | grep -v "grep" | tail -n 1 | awk '{print $2}')"
            ;;
    esac
}



socat -U - UNIX-CONNECT:"$HYPR_SOCKET" | while read -r line; do
    handle "$line"
done

#hyprctl workspaces | grep "workspace ID" | grep -v "grep" | tail -n 1 | awk '{print $3}'  

