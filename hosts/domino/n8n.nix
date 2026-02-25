{config, ...}: {
  sops.secrets = {
    "n8n-runners-auth-token" = {
      sopsFile = ../../secrets/domino/n8n.yaml;
      key = "runners-auth-token";
    };
    "encryption-key" = {
      sopsFile = ../../secrets/domino/n8n.yaml;
      key = "encryption-key";
    };
  };

  services.n8n = {
    enable = true;
    taskRunners.enable = true;
    environment = {
      DB_TYPE = "postgresdb";
      DB_POSTGRESDB_HOST = "/run/postgresql";
      DB_POSTGRESDB_DATABASE = "n8n";
      DB_POSTGRESDB_USER = "n8n";

      N8N_PORT = 7788;
      N8N_EDITOR_BASE_URL = "https://n8n.pikpok.xyz";
      WEBHOOK_URL = "https://n8n.pikpok.xyz/";

      N8N_RUNNERS_AUTH_TOKEN_FILE = config.sops.secrets."n8n-runners-auth-token".path;
      N8N_ENCRYPTION_KEY_FILE = config.sops.secrets."encryption-key".path;
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = ["n8n"];
    ensureUsers = [
      {
        name = "n8n";
        ensureDBOwnership = true;
      }
    ];
  };
}
