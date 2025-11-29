{pkgs, ...}: {
  services.postgresql = {
    package = pkgs.postgresql_18;
    enable = true;
    enableTCPIP = true;
    settings = {
      port = 5432;
    };
    ensureDatabases = ["teslamate" "mautrix-gmessages" "mautrix-signal" "mautrix-meta-messenger" "mautrix-whatsapp" "windmill"];
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
      {
        name = "windmill";
        ensureDBOwnership = true;
      }
    ];
    # TODO: Remove 10.88.0.1/16 once we get rid of all Docker containers connecting to Postgres
    # TODO: Remove 127.0.0.1/32 once https://github.com/teslamate-org/teslamate/pull/4456 is merged
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
      host  all       all     10.88.0.1/16   trust
      host  all       all     127.0.0.1/32   trust
    '';
  };
}
