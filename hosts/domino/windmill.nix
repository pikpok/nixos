{
  virtualisation.oci-containers = {
    containers = {
      windmill-server = {
        image = "ghcr.io/windmill-labs/windmill:1.463.1";
        environment = {
          MODE = "server";
          DATABASE_URL = "postgres://windmill@host.docker.internal/windmill?sslmode=disable";
        };
        ports = ["8000:8000"];
      };

      windmill-worker = {
        image = "ghcr.io/windmill-labs/windmill:1.463.1";
        environment = {
          MODE = "worker";
          WORKER_GROUP = "default";
          DATABASE_URL = "postgres://windmill@host.docker.internal/windmill?sslmode=disable";
        };
      };

      windmill-worker-native = {
        image = "ghcr.io/windmill-labs/windmill:1.463.1";
        environment = {
          MODE = "worker";
          WORKER_GROUP = "native";
          NUM_WORKERS = "8";
          SLEEP_QUEUE = "200";
          DATABASE_URL = "postgres://windmill@host.docker.internal/windmill?sslmode=disable";
        };
      };
    };
  };
}
