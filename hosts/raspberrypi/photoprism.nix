{
  services.photoprism = {
    enable = true;
    storagePath = "/var/lib/private/photoprism/photoprism-storage";
    originalsPath = "/mnt/nas/Photos/photoprism";
    importPath = "/mnt/nas/Photos/photoprism-import";
    settings = {
      PHOTOPRISM_ORIGINALS_LIMIT = "10000";
      PHOTOPRISM_WORKERS = "2";
      PHOTOPRISM_HTTP_COMPRESSION = "gzip";
      PHOTOPRISM_DATABASE_DRIVER = "sqlite";
      PHOTOPRISM_SITE_URL = "http://10.77.0.7:2342/";
    };
    address = "0.0.0.0";
  };

  systemd.timers."photoprism-index" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 03:00:00";
      Unit = "photoprism-index.service";
    };
  };

  systemd.services."photoprism-index" = {
    script = ''
      set -eu
      /var/lib/photoprism/photoprism-manage index
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
