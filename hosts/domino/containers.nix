{config, ...}: let
  pihole-version = "2024.07.0";
  home-assistant-version = "2025.1.0";
in {
  sops.secrets."pihole" = {
    sopsFile = ../../secrets/domino/pihole.env;
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
    };
  };
}
