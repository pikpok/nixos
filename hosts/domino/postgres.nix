{pkgs, ...}: {
  services.postgresql = {
    package = pkgs.postgresql_16;
    enable = true;
    enableTCPIP = true;
    settings = {
      port = 5432;
    };
    ensureDatabases = ["teslamate" "mautrix-gmessages" "mautrix-signal" "mautrix-meta-messenger" "mautrix-whatsapp"];
    ensureUsers = [
      {
        name = "teslamate";
        ensureDBOwnership = true;
      }
      {
        name = "mautrix-gmessages";
        ensureDBOwnership = true;
      }
      {
        name = "mautrix-signal";
        ensureDBOwnership = true;
      }
      {
        name = "mautrix-meta-messenger";
        ensureDBOwnership = true;
      }
      {
        name = "mautrix-whatsapp";
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
