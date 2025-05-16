let
  teslamate-abrp-version = "3.3.0";
in {
  sops.secrets."teslamate" = {
    sopsFile = ../../secrets/domino/teslamate.env;
    format = "dotenv";
  };
  sops.secrets."teslamate-abrp" = {
    sopsFile = ../../secrets/domino/teslamate-abrp.env;
    format = "dotenv";
  };

  virtualisation.oci-containers.containers.teslamate-abrp = {
    image = "fetzu/teslamate-abrp:${teslamate-abrp-version}";
    environmentFiles = ["/run/secrets/teslamate-abrp"];
    environment = {
      MQTT_SERVER = "host.docker.internal";
      CAR_NUMBER = "1";
    };
  };

  services.teslamate = {
    enable = true;
    secretsFile = "/run/secrets/teslamate";
    listenAddress = "127.0.0.1";
    port = 4000;
    virtualHost = "teslamate.pikpok.xyz";
    # TODO: use psql socket once https://github.com/teslamate-org/teslamate/pull/4456 is merged
    postgres = {
      enable_server = false;
      user = "teslamate";
      database = "teslamate";
    };
    grafana.enable = false;
    mqtt.enable = true;
  };
}
