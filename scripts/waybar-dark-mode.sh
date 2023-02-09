status=$(gsettings get org.gnome.desktop.interface color-scheme)

show() {
    if [ "$status" == "'prefer-light'" ]; then
        printf '{"text": "💡", "class": "on"}\n'
    else
        printf '{"text": "⚰️", "class": "off"}\n'
    fi
}

toggle() {
    if [ "$status" == "'prefer-light'" ]; then
        gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    else
        gsettings set org.gnome.desktop.interface color-scheme prefer-light
    fi
    pkill -SIGRTMIN+2 .waybar-wrapped
}

[ $# -gt 0 ] && toggle || show

