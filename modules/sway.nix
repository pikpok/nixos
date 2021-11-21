{ pkgs, home-manager, ... }:
let
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
  gsettingsCommand = ''
    ${gsettingsScript} \
      gtk-theme:gtk-theme-name \
      icon-theme:gtk-icon-theme-name \
      cursor-theme:gtk-cursor-theme-name
  '';
in {
  imports = [ ./waybar ];

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    # PBP only, for Alacritty to work
    PAN_MESA_DEBUG = "gl3";
  };

  environment.systemPackages = with pkgs; [
    alacritty
    nextcloud-client
    keepassxc
    waybar
    wofi
    xdg-utils
    pavucontrol
    pamixer
    polkit_gnome
    brightnessctl
    wl-clipboard
  ];

  programs.sway.enable = true;

  fonts.fonts = with pkgs; [ font-awesome hack-font ];

  home-manager.users.pikpok = {
    gtk = {
      enable = true;
      iconTheme = {
        name = "Adwaita";
        package = pkgs.gnome.adwaita-icon-theme;
      };
      theme = {
        name = "Adwaita";
        package = pkgs.gnome.gnome_themes_standard;
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

    programs.mako = {
      enable = true;
      backgroundColor = "#273238";
      borderColor = "#273238";
      extraConfig = ''
        [mode=dnd]
        invisible=1
      '';
    };

    wayland.windowManager.sway = {
      enable = true;
      systemdIntegration = true;
      wrapperFeatures.gtk = true;
      extraConfig = ''
        bindsym --release Print exec grim \"screenshot-$(date +%Y%m%d%H%M%S).png"
        bindsym --release Ctrl+Print exec grim - | wl-copy
        bindsym --release Shift+Print exec grim -g \"$(slurp)" \"screenshot-$(date +%Y%m%d%H%M%S).png"
        bindsym --release Ctrl+Shift+Print exec grim -g \"$(slurp)" - | wl-copy
      '';
      config = rec {
        startup = [
          {
            always = true;
            command = "${gsettingsCommand}";
          }
          {
            command =
              "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          }
          {
            command = "mako";
          }
          # Sleep to make sure tray (waybar) loads first
          { command = "sleep 10 && nextcloud"; }
        ];
        modifier = "Mod4";
        window.border = 0;
        terminal = "alacritty";
        input = {
          "*" = {
            tap = "enabled";
            xkb_layout = "pl";
          };
        };
        gaps.inner = 10;
        defaultWorkspace = "1";
        bars = [{ command = "${pkgs.waybar}/bin/waybar"; }];
        output = { "*" = { bg = "${./wallpaper.jpg} fill"; }; };
        keybindings = {
          "${modifier}+Return" = "exec ${terminal}";
          "${modifier}+d" = "exec wofi --show run";
          "${modifier}+Shift+b" = "exec /home/pikpok/.local/bin/btmenu";
          "${modifier}+Shift+c" = "reload";
          "${modifier}+Shift+e" = "exit";
          "${modifier}+Shift+q" = "kill";
          "${modifier}+r" = ''mode "resize"'';

          "XF86Display" = "output eDP-1 toggle";
          "XF86AudioRaiseVolume" = "exec pamixer -i 5";
          "XF86AudioLowerVolume" = "exec pamixer -d 5";
          "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "XF86AudioMicMute" =
            "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";
          "XF86AudioPlay" = "exec playerctl play-pause";
          "XF86AudioPause" = "exec playerctl pause";
          "XF86AudioNext" = "exec playerctl next";
          "XF86AudioPrev" = "exec playerctl previous";
          "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
          "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
          "${modifier}+Left" = "focus left";
          "${modifier}+Down" = "focus down";
          "${modifier}+Up" = "focus up";
          "${modifier}+Right" = "focus right";
          "${modifier}+Shift+Left" = "move left";
          "${modifier}+Shift+Down" = "move down";
          "${modifier}+Shift+Up" = "move up";
          "${modifier}+Shift+Right" = "move right";
          "${modifier}+1" = "workspace 1";
          "${modifier}+2" = "workspace 2";
          "${modifier}+3" = "workspace 3";
          "${modifier}+4" = "workspace 4";
          "${modifier}+5" = "workspace 5";
          "${modifier}+6" = "workspace 6";
          "${modifier}+7" = "workspace 7";
          "${modifier}+8" = "workspace 8";
          "${modifier}+9" = "workspace 9";
          "${modifier}+0" = "workspace 10";
          "${modifier}+Shift+1" = "move container to workspace 1";
          "${modifier}+Shift+2" = "move container to workspace 2";
          "${modifier}+Shift+3" = "move container to workspace 3";
          "${modifier}+Shift+4" = "move container to workspace 4";
          "${modifier}+Shift+5" = "move container to workspace 5";
          "${modifier}+Shift+6" = "move container to workspace 6";
          "${modifier}+Shift+7" = "move container to workspace 7";
          "${modifier}+Shift+8" = "move container to workspace 8";
          "${modifier}+Shift+9" = "move container to workspace 9";
          "${modifier}+Shift+0" = "move container to workspace 10";
          "${modifier}+Ctrl+Shift+right" = "move workspace to output right";
          "${modifier}+Ctrl+Shift+left" = "move workspace to output left";
          "${modifier}+Ctrl+Shift+up" = "move workspace to output up";
          "${modifier}+Ctrl+Shift+down" = "move workspace to output down";
          "${modifier}+s" = "layout stacking";
          "${modifier}+w" = "layout tabbed";
          "${modifier}+e" = "layout toggle split";
          "${modifier}+f" = "fullscreen";
          "${modifier}+Shift+space" = "floating toggle";
          "${modifier}+Shift+s" = "sticky toggle";
          "${modifier}+space" = "focus mode_toggle";
          "${modifier}+a" = "focus parent";
        };
      };
    };

  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
      gtkUsePortal = true;
    };
  };

  services.gnome.gnome-keyring.enable = true;
}
