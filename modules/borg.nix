{
  sops.secrets."borgbase/ssh_key" = {};
  sops.secrets."borgbase/passphrase" = {};

  services.borgbackup.jobs."borgbase" = {
    paths = [
      "/etc/NetworkManager/system-connections/"
      "/var/lib/bluetooth/"
      "/home"
    ];
    exclude = [
      "**/node_modules"
      "/home/*/.cache"
      "/home/*/.local/var"
      "/home/*/.config/Code"
      "/home/*/dev/mi5"
      "/home/*/go"
      "/home/*/.vscode"
      "/home/*/Downloads"
      "/home/*/Nextcloud"
    ];
    repo = "m3wwh76g@m3wwh76g.repo.borgbase.com:repo";
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat /run/secrets/borgbase/passphrase";
    };
    environment.BORG_RSH = "ssh -i /run/secrets/borgbase/ssh_key";
    compression = "auto,lzma";
    startAt = "hourly";
  };
}
