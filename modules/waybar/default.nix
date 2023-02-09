{
  pkgs,
  lib,
  home-manager,
  inputs,
  ...
}: let
  waybarDnd =
    pkgs.runCommandLocal "waybar-dnd"
    {nativeBuildInputs = [pkgs.makeWrapper];}
    ''
      makeWrapper ${../../scripts/waybar-dnd.sh} $out/bin/waybar-dnd \
        --prefix PATH : ${lib.makeBinPath [pkgs.mako]}
    '';
  waybarDarkMode =
    pkgs.runCommandLocal "waybar-dark-mode"
    {nativeBuildInputs = [pkgs.makeWrapper];}
    ''
      makeWrapper ${../../scripts/waybar-dark-mode.sh} $out/bin/waybar-dark-mode \
        --prefix PATH : ${lib.makeBinPath [pkgs.glib]}
    '';
in {
  home-manager.users.pikpok = {
    programs.waybar = {
      enable = true;
      settings = [
        {
          layer = "top";
          position = "top";
          modules-left = ["sway/workspaces" "sway/mode"];
          modules-right = [
            "custom/dark-mode"
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
          "sway/mode" = {"format" = ''<span style="italic">{}</span>'';};
          "idle_inhibitor" = {
            "format" = "{icon}";
            "format-icons" = {
              "activated" = "";
              "deactivated" = "";
            };
          };
          "tray" = {"spacing" = 10;};
          "clock" = {
            "locale" = "C";
            "format" = "{:%Y-%m-%d %H:%M}";
            "tooltip-format" = ''
              <big>{:%Y %B}</big>
              <tt><small>{calendar}</small></tt>'';
            "on-click" = "gsimplecal";
          };
          "cpu" = {"format" = " {usage}%";};
          "memory" = {
            "format" = " {}%";
            "tooltip" = "{used:0.1f}G/{total:0.1f}G ";
          };
          "backlight" = {
            "format" = "{icon} {percent}%";
            "format-icons" = ["" ""];
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
            "format-icons" = ["" "" "" "" ""];
          };
          "network" = {
            "interface" = "wl*";
            "format-wifi" = "";
            "format-linked" = "{ifname} (No IP) ";
            "format-disconnected" = "";
            "format-alt" = "{ifname}: {ipaddr}/{cidr}";
            "tooltip-format-wifi" = "{essid} ({signalStrength}%)";
            "on-click" = "${pkgs.networkmanager_dmenu}/bin/networkmanager_dmenu";
            "on-click-middle" = "nm-connection-editor";
          };
          "network#ethernet" = {
            "interface" = "enp*";
            "format-ethernet" = "";
            "format-alt" = "{ifname}: {ipaddr}/{cidr}";
            "tooltip-format" = "{ifname}: {ipaddr}/{cidr}";
            "on-click" = "${pkgs.networkmanager_dmenu}/bin/networkmanager_dmenu";
            "on-click-middle" = "nm-connection-editor";
          };
          "network#vpn" = {
            "interface" = "tun*";
            "format-ethernet" = "";
            "format-alt" = "{ifname}: {ipaddr}/{cidr}";
            "tooltip-format-ethernet" = "VPN {ifname}: {ipaddr}/{cidr}";
            "on-click" = "${pkgs.networkmanager_dmenu}/bin/networkmanager_dmenu";
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
              "default" = ["" "" ""];
            };
            "on-click" = "${pkgs.pavucontrol}/bin/pavucontrol";
          };
          "custom/media" = {
            "format" = "{icon}{}";
            "return-type" = "json";
            "format-icons" = {
              "Playing" = " ";
              "Paused" = " ";
            };
            "max-length" = 70;
            "exec" = "${pkgs.playerctl}/bin/playerctl -a metadata --format '{\"text\": \"{{playerName}}: {{artist}} - {{markup_escape(title)}}\", \"tooltip\": \"{{playerName}} : {{markup_escape(title)}}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}' -F";
            "on-click" = "${pkgs.playerctl}/bin/playerctl play-pause";
          };
          "custom/dnd" = {
            "exec" = "${waybarDnd}/bin/waybar-dnd";
            "return-type" = "json";
            "signal" = 2;
            "interval" = "once";
            "on-click" = "${waybarDnd}/bin/waybar-dnd toggle";
          };
          "custom/dark-mode" = {
            "exec" = "${waybarDarkMode}/bin/waybar-dark-mode";
            "return-type" = "json";
            "signal" = 2;
            "interval" = "once";
            "on-click" = "${waybarDarkMode}/bin/waybar-dark-mode toggle";
          };
        }
      ];
    };

    xdg.configFile."waybar/style.css".source = ./style.css;
  };
}
