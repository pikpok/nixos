marker="/tmp/waybar-dnd"

show() {
    if [ -e "$marker" ]; then
        printf '{"text": "", "class": "on"}\n'
    else
        printf '{"text": "", "class": "off"}\n'
    fi
}

toggle() {
    if [ -e "$marker" ]; then
        makoctl set-mode default
        rm -f "$marker"
    else
        makoctl set-mode dnd
        touch "$marker"
    fi
    sleep 1 && pkill -RTMIN+2 -x waybar
}

[ $# -gt 0 ] && toggle || show

