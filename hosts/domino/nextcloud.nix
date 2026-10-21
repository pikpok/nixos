{
  pkgs,
  config,
  lib,
  ...
}: {
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud35;
    # CVE-2026-109618 / CVE-2026-109619: use the security release until nixpkgs catches up.
    phpPackage =
      if lib.versionOlder pkgs.php84.version "8.4.27"
      then
        (pkgs.php84.override {
          version = "8.4.27";
          hash = "sha256-slMKh3xyL0sIyeF0owywi6wrfhkD7m6eMV8KqfX4LCQ=";
        }).withExtensions ({enabled, ...}:
          map (extension:
            if extension.extensionName == "filter"
            then
              # Load the shared filter extension in the new CGI regression tests.
              # https://github.com/NixOS/nixpkgs/commit/a5fc1be5b6c2d0c934143b57363aef9a15cce508
              extension.overrideAttrs (old: {
                postConfigure =
                  (old.postConfigure or "")
                  + ''
                    substituteInPlace \
                      tests/oom_filter_input.phpt \
                      tests/oom_filter_input_array.phpt \
                      tests/oom_filter_default_encoded.phpt \
                      --replace-fail "'-n'," "'-n', '-d', 'extension=$PWD/modules/filter.so',"
                  '';
              })
            else extension)
          enabled)
      else pkgs.php84;
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
