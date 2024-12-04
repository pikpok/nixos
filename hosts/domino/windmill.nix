{pkgs, ...}: let
  environment = {
    BUN_PATH = "${pkgs.bun}/bin/bun";
    DENO_PATH = "${pkgs.deno}/bin/deno";
    NPM_PATH = "${pkgs.nodejs}/bin/npm";
    NODE_BIN_PATH = "${pkgs.nodejs}/bin/node";
    UV_PATH = "${pkgs.uv}/bin/uv";
    FLOCK_PATH = "${pkgs.flock}/bin/flock";
    GO_PATH = "${pkgs.go}/bin/go";
    PYTHON_PATH = "${pkgs.python3}/bin/python3";
  };
in {
  services.windmill = {
    enable = true;
    baseUrl = "https://windmill.pikpok.xyz/";
  };

  systemd.services.windmill-worker.environment = environment;
  systemd.services.windmill-server.environment = environment;
}
