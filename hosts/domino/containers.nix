{
  pkgs,
  config,
  ...
}: let
  teslamate-version = "1.30.1";
  teslamate-abrp-version = "3.0.4";
  pihole-version = "2024.07.0";
  home-assistant-version = "2024.10.1";
in {
  sops.secrets."pihole" = {
    sopsFile = ../../secrets/domino/pihole.env;
    format = "dotenv";
  };
  sops.secrets."teslamate" = {
    sopsFile = ../../secrets/domino/teslamate.env;
    format = "dotenv";
  };
  sops.secrets."teslamate-abrp" = {
    sopsFile = ../../secrets/domino/teslamate-abrp.env;
    format = "dotenv";
  };

  virtualisation.podman = {
    autoPrune.enable = true;
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      pihole = {
        image = "pihole/pihole:${pihole-version}";
        extraOptions = [
          "--network=host"
          "--cap-add=NET_ADMIN" # Needed for DHCP
          "--cap-add=NET_RAW" # Needed for DHCP
        ];
        environmentFiles = ["/run/secrets/pihole"];
        environment = {
          TZ = config.time.timeZone;
          WEB_PORT = "81";
        };
        volumes = [
          "/var/lib/private/pihole/etc-pihole:/etc/pihole"
          "/var/lib/private/pihole/etc-dnsmasq.d:/etc/dnsmasq.d"
        ];
      };
      homeassistant = {
        volumes = [
          "/var/lib/private/home-assistant:/config"
          "/etc/localtime:/etc/localtime:ro"
          "/run/dbus:/run/dbus:ro"
        ];
        environment.TZ = config.time.timeZone;
        image = "ghcr.io/home-assistant/home-assistant:${home-assistant-version}";
        extraOptions = [
          "--network=host"
          # "--cap-add=NET_ADMIN" # Needed for BT
          # "--cap-add=NET_RAW" # Needed for BT
        ];
      };
      teslamate = {
        image = "teslamate/teslamate:${teslamate-version}";
        ports = ["4000:4000"];
        environmentFiles = ["/run/secrets/teslamate"];
        environment = {
          DATABASE_USER = "teslamate";
          DATABASE_NAME = "teslamate";
          DATABASE_HOST = "host.docker.internal";
          DATABASE_PASS = "";
          MQTT_HOST = "host.docker.internal";
          TZ = config.time.timeZone;
        };
      };
      teslamate-abrp = {
        image = "fetzu/teslamate-abrp:${teslamate-abrp-version}";
        environmentFiles = ["/run/secrets/teslamate-abrp"];
        environment = {
          MQTT_SERVER = "host.docker.internal";
          CAR_NUMBER = "1";
        };
      };
    };
  };

  services.postgresql = {
    package = pkgs.postgresql_16;
    enable = true;
    enableTCPIP = true;
    settings = {
      port = 5432;
    };
    ensureDatabases = ["teslamate"];
    ensureUsers = [
      {
        name = "teslamate";
        ensureDBOwnership = true;
      }
    ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
      host  all       all     10.88.0.1/16   trust
    '';
  };
}
