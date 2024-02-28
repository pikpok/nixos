{pkgs, ...}: {
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      pihole = {
        image = "pihole/pihole:2024.02.2";
        extraOptions = [
          "--network=host"
          "--cap-add=NET_ADMIN" # Needed for DHCP
          "--cap-add=NET_RAW" # Needed for DHCP
        ];
        environmentFiles = ["/root/pihole.env"];
        environment = {
          TZ = "Europe/Warsaw";
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
        environment.TZ = "Europe/Warsaw";
        image = "ghcr.io/home-assistant/home-assistant:2024.2.4";
        extraOptions = [
          "--network=host"
          "--cap-add=NET_ADMIN" # Needed for DHCP
          "--cap-add=NET_RAW" # Needed for DHCP
        ];
      };
      teslamate = {
        environmentFiles = ["/root/teslamate.env"];
        environment = {
          DATABASE_USER = "teslamate";
          DATABASE_NAME = "teslamate";
          DATABASE_HOST = "host.docker.internal";
          MQTT_HOST = "host.docker.internal";
          TZ = "Europe/Warsaw";
        };
        ports = ["4000:4000"];
        image = "teslamate/teslamate:1.28.3";
      };
      teslamate-abrp = {
        image = "fetzu/teslamate-abrp:3.0.0";
        environmentFiles = ["/root/teslamate-abrp.env"];
        environment = {
          MQTT_SERVER = "host.docker.internal";
          CAR_NUMBER = "1";
        };
      };
    };
  };

  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    port = 5432;
    authentication = pkgs.lib.mkOverride 10 ''
      #type database DBuser origin-address auth-method
      local all       all     trust
      # ipv4
      host  all      all     127.0.0.1/32   trust
      # podman network
      host  all      all     10.88.0.1/16   trust
      # ipv6
      host all       all     ::1/128        trust
    '';
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "10.77.0.7";
        http_port = 3000;
        domain = "10.77.0.7:3000";
      };
    };
  };
}
