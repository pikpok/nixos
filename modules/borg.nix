{
  services.borgbackup.jobs."borgbase" = {
    paths = [
      "/etc/NetworkManager/system-connections/"
      "/var/lib/bluetooth/"
      "/home"
    ];
    exclude = [
      "**/node_modules"
      "/home/*/.cache"
      "/home/*/.config/Code"
      "/home/*/.vscode"
      "/home/*/Downloads"
      "/home/*/Nextcloud"
    ];
    repo = "q038gaqn@q038gaqn.repo.borgbase.com:repo";
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat /root/borgbackup/passphrase";
    };
    environment.BORG_RSH = "ssh -i /root/borgbackup/ssh_key";
    compression = "auto,lzma";
    startAt = "hourly";
  };
}
