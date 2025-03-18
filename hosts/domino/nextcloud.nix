{
  pkgs,
  config,
  ...
}: {
  sops.secrets."nextcloud-admin-password" = {
    sopsFile = ../../secrets/${config.networking.hostName}/nextcloud.yaml;
    owner = "nextcloud";
    group = "nextcloud";
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud31;
    notify_push.enable = true;
    maxUploadSize = "10G";
    hostName = "c.pikpok.xyz";
    https = true;
    database = {
      createLocally = true;
    };
    settings = {
      trusted_proxies = [
        "127.0.0.1"
        "192.168.100.7"
        "::1"
      ];
    };
    config = {
      adminpassFile = "/run/secrets/nextcloud-admin-password";
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbname = "nextcloud";
      dbhost = "/run/postgresql";
    };
    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps) notes contacts calendar tasks deck gpoddersync notify_push news;

      timemanager = pkgs.fetchNextcloudApp {
        url = "https://github.com/te-online/timemanager/archive/refs/tags/v0.3.18.tar.gz";
        sha256 = "sha256-BtYFO550qA4fnPwz9pQ7mpjoL9bLJsTo65xQziWBLAw=";
        license = "agpl3Only";
      };
    };
  };

  services.nginx.virtualHosts."${config.services.nextcloud.hostName}".listen = [
    {
      addr = "127.0.0.1";
      port = 8081;
    }
  ];
}
