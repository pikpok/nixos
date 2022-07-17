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
    pkill -SIGRTMIN+2 .waybar-wrapped
}

[ $# -gt 0 ] && toggle || show

