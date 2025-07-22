{config, ...}: let
  home-assistant-version = "2025.7.3";
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

  services.zigbee2mqtt = {
    enable = true;
    settings = {
      mqtt.server = "mqtt://localhost:1883";
      homeassistant.enabled = true;
      frontend = {
        enabled = true;
        port = 8321;
      };
      serial = {
        adapter = "ember";
        port = "/dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_e03b2b0cb849ef119403c98cff00cc63-if00-port0";
      };
    };
  };
}
