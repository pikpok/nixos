{pkgs, ...}: {
  services.snapserver = {
    enable = true;
    settings = {
      stream = {
        source = [
          "airplay://${pkgs.shairport-sync-airplay2}/bin/shairport-sync?name=Airplay&codec=null"
          "librespot://${pkgs.librespot}/bin/librespot?name=Spotify&devicename=Snapcast&codec=null"
          "meta:///Spotify/Airplay?name=Meta&codec=flac"
        ];
      };
      tcp.enabled = true;
      http.enabled = true;
    };
  };

  systemd.services = {
    nqptp = {
      description = "Network Precision Time Protocol for Shairport Sync";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      serviceConfig = {
        ExecStart = "${pkgs.nqptp}/bin/nqptp";
        Restart = "always";
        RestartSec = "5s";
      };
    };
  };

  services.music-assistant = {
    enable = true;
    providers = [
      "snapcast"
      "spotify"
      "radiobrowser"
      "gpodder"
      "filesystem_local"
      "chromecast"
    ];
  };
}
