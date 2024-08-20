{
  pkgs,
  lib,
  ...
}: {
  services.photoprism = {
    enable = true;
    # Override photoprism, make sure it uses ffmpeg-full that includes Intel QSV support
    package = pkgs.photoprism.overrideAttrs (oldAttrs: {
      pname = oldAttrs.pname + "-ffmpeg-full";
      postInstall = ''
        substituteInPlace $out/bin/photoprism --replace-fail "${pkgs.ffmpeg_7}/bin/ffmpeg" "${pkgs.ffmpeg_7-full}/bin/ffmpeg"
      '';
    });
    storagePath = "/mnt/nas/photoprism-storage";
    originalsPath = "/mnt/nas/Photos/photoprism";
    importPath = "/mnt/nas/Photos/photoprism-import";
    settings = {
      PHOTOPRISM_ORIGINALS_LIMIT = "10000";
      PHOTOPRISM_HTTP_COMPRESSION = "gzip";
      PHOTOPRISM_DATABASE_DRIVER = "mysql";
      PHOTOPRISM_DATABASE_NAME = "photoprism";
      PHOTOPRISM_DATABASE_SERVER = "/run/mysqld/mysqld.sock";
      PHOTOPRISM_DATABASE_USER = "photoprism";
      PHOTOPRISM_SITE_URL = "https://photoprism.pikpok.xyz/";
      PHOTOPRISM_FFMPEG_ENCODER = "intel";
    };
    address = "0.0.0.0";
  };

  users = {
    groups.photoprism = {
      gid = 990;
    };
    users.photoprism = {
      uid = 991;
      isSystemUser = true;
      group = "photoprism";
    };
    groups.share.members = ["photoprism"];
    groups.video.members = ["photoprism"];
    groups.render.members = ["photoprism"];
    users.pikpok.extraGroups = ["photoprism"];
  };

  systemd.services.photoprism.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = lib.mkForce "photoprism";
    Group = lib.mkForce "photoprism";
    PrivateDevices = lib.mkForce false;
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureDatabases = ["photoprism"];
    ensureUsers = [
      {
        name = "photoprism";
        ensurePermissions = {
          "photoprism.*" = "ALL PRIVILEGES";
        };
      }
    ];
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
