{
  services.mpd = {
    enable = true;
    settings = {
      music_directory = "/mnt/nas/Music";
      bind_to_address = "any";
      audio_output = [
        {
          type = "pipewire";
          name = "PipeWire";
        }
      ];
    };

    startWhenNeeded = true;

    user = "pikpok";
  };

  systemd.services.mpd.environment = {
    # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
    XDG_RUNTIME_DIR = "/run/user/1000"; # should match pikpok user
  };
}
