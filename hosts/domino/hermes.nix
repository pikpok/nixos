{
  config,
  pkgs,
  ...
}: let
  # Hermes v0.22.5-desktop; bump the digest deliberately.
  image = "docker.io/nousresearch/hermes-agent@sha256:b7837e696eebce08495f6984a79a0a6a7ef696af746d407debff26d88473a389";
  dataDir = "/var/lib/hermes";
  # `ssh mac` from the container: a shell on the owner's Mac.
  macSshConfig = pkgs.writeText "mac.conf" ''
    Host mac
      HostName pikpok-mbp.lan
      User pikpok
      IdentityFile /opt/data/.ssh/id_mac
      UserKnownHostsFile /etc/hermes/mac-known-hosts
      HostKeyAlias pikpok-mbp
      BatchMode yes
      ServerAliveInterval 30
  '';
  # Force-install uBlock Origin Lite and Consent-O-Matic from the Web Store.
  chromePolicy = (pkgs.formats.json {}).generate "hermes-chrome-policy.json" {
    ExtensionInstallForcelist = map (id: "${id};https://clients2.google.com/service/update2/crx") [
      "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin Lite
      "mdjildafknihdffpkfmmpnpoiajfjnjd" # Consent-O-Matic
    ];
  };
  # Managed settings: they override /opt/data/config.yaml and can't be changed from chat.
  hermesConfig = (pkgs.formats.yaml {}).generate "hermes-config.yaml" {
    model = {
      provider = "openai-codex";
      default = "gpt-6.1-sol";
    };
    # Start Bot Screen (Xfce desktop over VNC) on the first headed browser use.
    # The browser.* settings are only read from /opt/data/config.yaml; see README.
    bot_desktop.auto_start = true;
    # The Mac's desktop: Cua Driver's MCP server over SSH, which starts the
    # signed CuaDriver.app there.
    mcp_servers.mac = {
      command = "/usr/bin/ssh";
      args = ["-T" "mac" "CUA_DRIVER_RS_TELEMETRY_ENABLED=0 /Applications/CuaDriver.app/Contents/MacOS/cua-driver mcp"];
      connect_timeout = 30;
      timeout = 60;
    };
    # Served at https://hermes.pikpok.xyz by Traefik through Podman's port forward.
    dashboard = {
      public_url = "https://hermes.pikpok.xyz";
      trusted_proxies = ["10.88.0.1"];
    };
  };
in {
  # Matches the image's hermes user, which owns the state directory.
  users.groups.hermes.gid = 10000;
  users.users.hermes = {
    isSystemUser = true;
    uid = 10000;
    group = "hermes";
    home = dataDir;
  };
  systemd.tmpfiles.rules = ["d ${dataDir} 0700 hermes hermes -"];

  # Telegram bot token/allowlist and dashboard login.
  # The ChatGPT login lives in /var/lib/hermes/auth.json.
  sops.secrets.hermes = {
    sopsFile = ../../secrets/domino/hermes.env;
    format = "dotenv";
    owner = "hermes";
    group = "hermes";
    mode = "0400";
    restartUnits = ["podman-hermes.service"];
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers.hermes = {
      inherit image;
      cmd = ["gateway" "run"];
      # Dashboard, for Traefik (hermes.pikpok.xyz).
      ports = ["127.0.0.1:9119:9119"];
      environment = {
        # Regular Google Chrome, for the agent and Bot Screen alike.
        AGENT_BROWSER_EXECUTABLE_PATH = "${pkgs.google-chrome}/bin/google-chrome-stable";
        HERMES_DASHBOARD = "1";
        TZ = "Europe/Warsaw";
      };
      volumes = [
        "${dataDir}:/opt/data"
        # Google Chrome and its dependencies.
        "/nix/store:/nix/store:ro"
        "${chromePolicy}:/etc/opt/chrome/policies/managed/hermes.json:ro"
        "${hermesConfig}:/etc/hermes/config.yaml:ro"
        "${config.sops.secrets.hermes.path}:/etc/hermes/.env:ro"
        "${./hermes/mac-known-hosts}:/etc/hermes/mac-known-hosts:ro"
        "${macSshConfig}:/etc/ssh/ssh_config.d/mac.conf:ro"
        "${./hermes/SOUL.md}:/opt/data/SOUL.md:ro"
        # Hermes only launches Chromium without its nested sandbox when it sees
        # Docker's marker; Podman doesn't create one.
        "${pkgs.writeText "dockerenv" ""}:/.dockerenv:ro"
      ];
      extraOptions = ["--shm-size=1g"];
    };
  };
}
