# Private Matrix homeserver (Tuwunel, the successor of conduwuit) for Hermes and
# a few people. LAN/WireGuard only and no federation, so it only talks to its own
# users. New accounts need the registration token from SOPS; the first account
# registered becomes server admin.
{config, ...}: let
  serverName = "matrix.pikpok.xyz";
in {
  # TUWUNEL_REGISTRATION_TOKEN
  sops.secrets.tuwunel = {
    sopsFile = ../../secrets/domino/tuwunel.env;
    format = "dotenv";
    restartUnits = ["tuwunel.service"];
  };

  services.matrix-tuwunel = {
    enable = true;
    environmentFile = config.sops.secrets.tuwunel.path;
    settings.global = {
      server_name = serverName;
      # Listens on localhost:6167; Traefik serves https://matrix.pikpok.xyz.
      allow_federation = false;
      trusted_servers = [];
      allow_registration = true;
      # Clients find the server from @user:matrix.pikpok.xyz.
      well_known.client = "https://${serverName}";
    };
  };
}
