{
  pkgs,
  home-manager,
  ...
}: let
  gsettings = "${pkgs.glib}/bin/gsettings";
  gsettingsScript = pkgs.writeShellScript "gsettings-auto.sh" ''
    expression=""
    for pair in "$@"; do
      IFS=:; set -- $pair
      expressions="$expressions -e 's:^$2=(.*)$:${gsettings} set org.gnome.desktop.interface $1 \1:e'"
    done
    IFS=
    echo "" >/tmp/gsettings.log
    echo exec sed -E $expressions "''${XDG_CONFIG_HOME:-$HOME/.config}"/gtk-3.0/settings.ini &>>/tmp/gsettings.log
    eval exec sed -E $expressions "''${XDG_CONFIG_HOME:-$HOME/.config}"/gtk-3.0/settings.ini &>>/tmp/gsettings.log
  '';
  gsettingsCommand = "${gsettingsScript} gtk-theme:gtk-theme-name icon-theme:gtk-icon-theme-name cursor-theme:gtk-cursor-theme-name";

  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme 'Dracula'
    '';
  };

  wallpaper = "${./wallpaper.jpg}";
  lockCommand = "${pkgs.swaylock}/bin/swaylock -f -i ${wallpaper}";
in {
  imports = [./waybar];

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    # Use Wayland for Chromium/Electron apps
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = with pkgs; [
    alacritty
    nextcloud-client
    keepassxc
    xdg-utils
    pavucontrol
    wayvnc
    shortwave
    evince
    xfce.thunar
    xfce.tumbler
    valent
  ];

  programs.sway.enable = true;

  services.getty.autologinUser = "pikpok";

  services.gvfs.enable = true;

  fonts.packages = with pkgs; [font-awesome];

  home-manager.users.pikpok = {
    gtk = {
      enable = true;
      iconTheme = {
        name = "Adwaita";
        package = pkgs.gnome.adwaita-icon-theme;
      };
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome.gnome-themes-extra;
      };
    };

    qt = {
      enable = true;
      platformTheme = "gnome";
      style = {
        package = pkgs.adwaita-qt;
        name = "adwaita";
      };
    };

    programs.zsh.loginExtra = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        export XDG_SESSION_TYPE=wayland
        mv sway.log sway.log.old
        exec Hyprland > ~/sway.log 2>&1
      fi
    '';

    services = {
      mako = {
        enable = true;
        backgroundColor = "#273238";
        borderColor = "#273238";
        extraConfig = ''
          on-button-middle=exec ${pkgs.mako}/bin/makoctl menu -n "$id" ${pkgs.wofi}/bin/wofi --show dmenu -p 'Select action: '

          [mode=dnd]
          invisible=1
        '';
      };

      swayidle = {
        enable = true;
        events = [
          {
            event = "after-resume";
            command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
          }
          {
            event = "before-sleep";
            command = lockCommand;
          }
        ];
        timeouts = [
          {
            timeout = 300;
            command = lockCommand;
          }
          {
            timeout = 305;
            command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
            resumeCommand = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
          }
        ];
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        "$mod" = "SUPER";
        exec-once = [
          "${pkgs.waybar}/bin/waybar"
          "${pkgs.swaybg}/bin/swaybg -i ${wallpaper} -m fill"
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
          "mako"
          # Sleep to make sure tray (waybar) loads first
          "sleep 5 && nextcloud"
          "${pkgs.valent}/bin/valent"
        ];
        exec = gsettingsCommand;
        monitor = ",preferred,auto,2";
        bind = [
          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod, 6, workspace, 6"
          "$mod, 7, workspace, 7"
          "$mod, 8, workspace, 8"
          "$mod, 9, workspace, 9"
          "$mod, d, exec, ${pkgs.wofi}/bin/wofi --show run"

          "$mod, RETURN, exec, alacritty"
          "$mod, n, exec, ${pkgs.networkmanager_dmenu}/bin/networkmanager_dmenu"
          "$mod SHIFT, b, exec, ${../scripts/btmenu.sh}"
          "$mod SHIFT, e, exit"
          "$mod SHIFT, q, killactive"
          "$mod, l, exec, ${lockCommand}"
          "$mod, i, exec, ${pkgs.rofimoji}/bin/rofimoji"

          #       "XF86Display" = "output eDP-1 toggle";
          ",XF86AudioRaiseVolume, exec, ${pkgs.pamixer}/bin/pamixer -i 5"
          ",XF86AudioLowerVolume, exec, ${pkgs.pamixer}/bin/pamixer -d 5"
          ",XF86AudioMute, exec, ${pkgs.pamixer}/bin/pamixer -t"
          ",XF86AudioMicMute, exec, ${pkgs.pamixer}/bin/pamixer --default-source -t"

          ",XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
          ",XF86AudioPause, exec, ${pkgs.playerctl}/bin/playerctl pause"
          ",XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
          ",XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"

          ",XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 5%-"
          ",XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set +5%"

          "$mod, left, movefocus, l"
          "$mod, left, changegroupactive, b"
          "$mod, down, movefocus, d"
          "$mod, up, movefocus, u"
          "$mod, right, movefocus, r"
          "$mod, right, changegroupactive, f"
          "$mod SHIFT, left, movewindoworgroup, l"
          "$mod SHIFT, down, movewindoworgroup, d"
          "$mod SHIFT, up, movewindoworgroup, u"
          "$mod SHIFT, right, movewindoworgroup, r"

          "$mod SHIFT, 1, movetoworkspacesilent, 1"
          "$mod SHIFT, 2, movetoworkspacesilent, 2"
          "$mod SHIFT, 3, movetoworkspacesilent, 3"
          "$mod SHIFT, 4, movetoworkspacesilent, 4"
          "$mod SHIFT, 5, movetoworkspacesilent, 5"
          "$mod SHIFT, 6, movetoworkspacesilent, 6"
          "$mod SHIFT, 7, movetoworkspacesilent, 7"
          "$mod SHIFT, 8, movetoworkspacesilent, 8"
          "$mod SHIFT, 9, movetoworkspacesilent, 9"
          "$mod SHIFT, 0, movetoworkspacesilent, 10"
          "$mod CTRL_SHIFT, right, movecurrentworkspacetomonitor, r"
          "$mod CTRL_SHIFT, left, movecurrentworkspacetomonitor, l"
          "$mod CTRL_SHIFT, up, movecurrentworkspacetomonitor, u"
          "$mod CTRL_SHIFT, down, movecurrentworkspacetomonitor, d"
          "$mod, w, togglegroup,"
          "$mod, e, togglesplit,"
          "$mod, f, fullscreen,"
          "$mod SHIFT, space, togglefloating,"

          "SUPER, p, exec, ${pkgs.grimblast}/bin/grimblast copy active"
          "SUPER SHIFT, p, exec, ${pkgs.grimblast}/bin/grimblast copy area"
          "SUPER ALT, p, exec, ${pkgs.grimblast}/bin/grimblast copy output"
          "SUPER CTRL, p, exec, ${pkgs.grimblast}/bin/grimblast copy screen"
        ];
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
        gestures = {
          workspace_swipe = true;
        };
        general = {
          gaps_out = 10;
          gaps_in = 10;
        };
        input = {
          kb_layout = "pl";
          natural_scroll = true;
        };
        "input:touchpad" = {
          natural_scroll = true;
        };
      };
      extraConfig = ''
        # window resize
        bind = $mod, R, submap, resize

        submap = resize
        binde = , right, resizeactive, 10 0
        binde = , left, resizeactive, -10 0
        binde = , up, resizeactive, 0 -10
        binde = , down, resizeactive, 0 10
        bind = , escape, submap, reset
        submap = reset
      '';
    };
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
    };
  };

  services.gnome.gnome-keyring.enable = true;
}
