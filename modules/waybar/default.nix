{ pkgs, lib, home-manager, inputs, ... }: {
  nixpkgs.overlays = [ (import ./overlay.nix) ];

  home-manager.users.pikpok = {
    programs.waybar = {
      enable = true;
      settings = [{
        layer = "top";
        position = "top";
        modules-left = [ "sway/workspaces" "sway/mode" ];
        modules-right = [
          "custom/dnd"
          "idle_inhibitor"
          "pulseaudio"
          "custom/media"
          "network"
          "network#ethernet"
          "network#vpn"
          "cpu"
          "memory"
          "backlight"
          "battery"
          "clock"
          "tray"
        ];
        modules = {
          "sway/workspaces" = {
            "all-outputs" = false;
            "format" = "{icon}";
            "format-icons" = {
              "1" = "";
              "2" = "";
              "3" = "";
              "4" = "";
              "5" = "";
              "urgent" = "";
              "focused" = "";
              "default" = "";
            };
          };
          "sway/mode" = { "format" = ''<span style="italic">{}</span>''; };
          "idle_inhibitor" = {
            "format" = "{icon}";
            "format-icons" = {
              "activated" = "";
              "deactivated" = "";
            };
          };
          "tray" = { "spacing" = 10; };
          "clock" = {
            "locale" = "C";
            "format" = "{:%Y-%m-%d %H:%M}";
            "tooltip-format" = ''
              <big>{:%Y %B}</big>
              <tt><small>{calendar}</small></tt>'';
            "on-click" = "gsimplecal";
          };
          "cpu" = { "format" = " {usage}%"; };
          "memory" = {
            "format" = " {}%";
            "tooltip" = "{used:0.1f}G/{total:0.1f}G ";
          };
          "backlight" = {
            "format" = "{icon} {percent}%";
            "format-icons" = [ "" "" ];
          };
          "battery" = {
            "states" = {
              "warning" = 30;
              "critical" = 15;
            };
            "format-time" = "{H}h {M}m";
            "format-alt" = "{capacity}% {icon}";
            "format-charging" = " {capacity}%";
            "format-plugged" = " {capacity}%";
            "format-full" = " {capacity}%";
            "format" = "{time} ({capacity}%) {icon}";
            "format-icons" = [ "" "" "" "" "" ];
          };
          "network" = {
            "interface" = "wl*";
            "format-wifi" = "";
            "format-linked" = "{ifname} (No IP) ";
            "format-disconnected" = "";
            "format-alt" = "{ifname}: {ipaddr}/{cidr}";
            "tooltip-format-wifi" = "{essid} ({signalStrength}%)";
            "on-click" = "networkmanager_dmenu";
            "on-click-middle" = "nm-connection-editor";
          };
          "network#ethernet" = {
            "interface" = "enp*";
            "format-ethernet" = "";
            "format-alt" = "{ifname}: {ipaddr}/{cidr}";
            "tooltip-format" = "{ifname}: {ipaddr}/{cidr}";
            "on-click" = "networkmanager_dmenu";
            "on-click-middle" = "nm-connection-editor";
          };
          "network#vpn" = {
            "interface" = "tun*";
            "format-ethernet" = "";
            "format-alt" = "{ifname}: {ipaddr}/{cidr}";
            "tooltip-format-ethernet" = "VPN {ifname}: {ipaddr}/{cidr}";
            "on-click" = "networkmanager_dmenu";
            "on-click-middle" = "nm-connection-editor";
          };
          "pulseaudio" = {
            "format" = "{volume}% {icon} {format_source}";
            "format-bluetooth" = "{volume}% {icon} {format_source}";
            "format-muted" = " {format_source}";
            "format-source" = "{volume}% ";
            "format-source-muted" = "";
            "format-icons" = {
              "headphones" = "";
              "handsfree" = "";
              "headset" = "";
              "phone" = "";
              "portable" = "";
              "car" = "";
              "default" = [ "" "" "" ];
            };
            "on-click" = "pavucontrol";
          };
          "custom/media" = {
            "format" = " {}";
            "return-type" = "json";
            "max-length" = 40;
            "escape" = true;
            "exec" =
              "${pkgs.waybar-mpris}/bin/waybar-mpris --position --autofocus --order ARTIST:ALBUM:TITLE";
            "on-click" = "${pkgs.waybar-mpris}/bin/waybar-mpris --send toggle";
          };
          "custom/dnd" = {
            "exec" = "$HOME/.local/bin/waybar-dnd";
            "return-type" = "json";
            "signal" = 2;
            "interval" = "once";
            "on-click" = "$HOME/.local/bin/waybar-dnd toggle";
          };
        };
      }];
    };

    xdg.configFile."waybar/style.css".source = ./style.css;
  };
}
