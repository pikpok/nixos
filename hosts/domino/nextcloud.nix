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
    notify_push.enable = true;
    enable = true;
    maxUploadSize = "10G";
    package = pkgs.nextcloud30;
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
      inherit (config.services.nextcloud.package.packages.apps) notes contacts calendar tasks deck gpoddersync notify_push;

      timemanager = pkgs.fetchNextcloudApp {
        url = "https://github.com/te-online/timemanager/archive/refs/tags/v0.3.16.tar.gz";
        sha256 = "sha256-pFlKO8jGI5wat9986u3FFwZeTKZAH71PpVMwblzf/sU=";
        license = "agpl3Only";
      };

      # TODO: use news from nextcloud.package.packages.apps once it's updated >= 25.2.0
      news = pkgs.fetchNextcloudApp {
        url = "https://github.com/nextcloud/news/releases/download/25.2.0/news.tar.gz";
        sha256 = "sha256-jJmF98mNAapZPEASoH5b/hFLFhcxW5a/1q86FFMawyI=";
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
