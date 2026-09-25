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
    package = pkgs.nextcloud34;
    notify_push.enable = true;
    maxUploadSize = "10G";
    hostName = "c.pikpok.xyz";
    https = true;
    database = {
      createLocally = true;
    };
    phpOptions."opcache.interned_strings_buffer" = "32";
    settings = {
      default_phone_region = "PL";
      maintenance_window_start = 1;
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
      inherit (config.services.nextcloud.package.packages.apps) notes contacts calendar tasks deck gpoddersync news mail;

      timemanager = pkgs.fetchNextcloudApp {
        url = "https://github.com/te-online/timemanager/archive/refs/tags/v0.3.26.tar.gz";
        sha256 = "sha256-GM0e+bZkM9fhLIm7AFqucM7PPY3mqJ/+Z/JU1S7iOo4=";
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

  systemd.services.nextcloud-notify_push_setup = {
    after = ["traefik.service"];
    wants = ["traefik.service"];
  };
}
