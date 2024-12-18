{
  config,
  lib,
  ...
}: let
  serverName = "matrix.pikpok.xyz";
  defaultBridgeSettings = bridgeName: {
    bridge = {
      permissions = {
        "*" = "relay";
        "${serverName}" = "user";
        "@pikpok:${serverName}" = "admin";
      };
    };
    homeserver = {
      address = "http://localhost:6167";
      domain = serverName;
    };
    database = {
      type = "postgres";
      uri = "postgresql:///mautrix-${bridgeName}?host=/run/postgresql";
    };
    encryption = {
      allow = true;
      default = true;
      require = true;
      pickle_key = "$\{MAUTRIX_${builtins.replaceStrings ["-"] ["_"] (lib.toUpper bridgeName)}_ENCRYPTION_PICKLE_KEY\}";
    };
    backfill.enabled = true;
    double_puppet.secrets."${serverName}" = "as_token:$\{DOUBLEPUPPET_AS_TOKEN\}";
  };
in {
  services.conduwuit = {
    enable = true;
    settings = {
      global = {
        address = ["0.0.0.0"];
        server_name = serverName;
        database_backend = "rocksdb";
        well_known = {
          server = "${serverName}:443";
          client = "https://${serverName}";
        };
      };
    };
  };

  services.ntfy-sh = {
    enable = true;
    settings.base-url = "https://ntfy.pikpok.xyz";
  };

  # TODO: add declarative config for mautrix-gmessages
  virtualisation.oci-containers.containers.mautrix-gmessages = {
    image = "dock.mau.dev/mautrix/gmessages:v0.5.2";
    volumes = ["/var/lib/private/mautrix-gmessages:/data"];
    ports = ["29336:29336"];
  };

  nixpkgs.config.permittedInsecurePackages = ["olm-3.2.16"];

  sops.secrets = {
    "mautrix-signal" = {
      sopsFile = ../../secrets/${config.networking.hostName}/mautrix-signal.env;
      format = "dotenv";
    };
    "mautrix-meta-messenger" = {
      sopsFile = ../../secrets/${config.networking.hostName}/mautrix-meta-messenger.env;
      format = "dotenv";
    };
  };

  services.mautrix-signal = {
    enable = true;
    environmentFile = "/run/secrets/mautrix-signal";
    settings = defaultBridgeSettings "signal";
  };

  services.mautrix-meta = {
    instances.messenger = {
      enable = true;
      environmentFile = "/run/secrets/mautrix-meta-messenger";
      settings =
        defaultBridgeSettings "meta-messenger"
        // {
          network.mode = "messenger";
          appservice = {
            id = "messenger";
            bot.username = "messengerbot";
          };
        };
    };
  };

  # TODO: Waits for https://github.com/NixOS/nixpkgs/pull/350448
  # services.mautrix-whatsapp = {
  #   enable = true;
  #   settings = defaultBridgeSettings "whatsapp";
  # };
}
