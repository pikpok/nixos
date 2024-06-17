{
  services.mpd = {
    enable = true;
    musicDirectory = "/mnt/nas/Music";
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "PipeWire"
      }
    '';

    # Optional:
    network.listenAddress = "any"; # if you want to allow non-localhost connections
    startWhenNeeded = true; # systemd feature: only start MPD service upon connection to its socket

    user = "pikpok";
  };

  systemd.services.mpd.environment = {
    # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
    XDG_RUNTIME_DIR = "/run/user/1000"; # should match pikpok user
  };
}
