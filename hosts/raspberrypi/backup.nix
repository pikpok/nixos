{pkgs, ...}: {
  systemd.timers."xoler-backup" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 21:21:00";
      Unit = "xoler-backup.service";
    };
  };

  systemd.services."xoler-backup" = {
    script = ''
      set -eu
      cd /mnt/nas/Backups/xoler/ && ${pkgs.bash}/bin/bash backup.sh
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "pikpok";
    };
  };

  systemd.timers."vps-backup" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 13:21:00";
      Unit = "vps-backup.service";
    };
  };

  systemd.services."vps-backup" = {
    script = ''
      set -eu
      cd /mnt/nas/Backups/vps/ && ${pkgs.bash}/bin/bash backup.sh
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "pikpok";
    };
  };
}
