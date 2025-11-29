let
  version = "1.121.3";
in {
  virtualisation.oci-containers.containers.n8n = {
    image = "docker.n8n.io/n8nio/n8n:${version}";
    ports = ["5678:5678"];
    environment = {
      DB_TYPE = "postgresdb";
      DB_POSTGRESDB_HOST = "/run/postgresql";
      DB_POSTGRESDB_DATABASE = "n8n";
      DB_POSTGRESDB_USER = "n8n";
      GENERIC_TIMEZONE = "Europe/Warsaw";
      N8N_DIAGNOSTICS_ENABLED = "false";
      WEBHOOK_URL = "https://n8n.pikpok.xyz/";
    };
    volumes = [
      "/var/lib/private/n8n:/home/node/.n8n"
      "/run/postgresql:/run/postgresql"
    ];
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
