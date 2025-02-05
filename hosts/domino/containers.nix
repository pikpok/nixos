{config, ...}: let
  home-assistant-version = "2025.1.0";
in {
  virtualisation.podman = {
    autoPrune.enable = true;
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
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
