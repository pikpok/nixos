{ lib, stdenv, buildGoModule, fetchgit }:

buildGoModule rec {
  pname = "waybar-mpris";
  version = "0.1.0";

  src = fetchgit {
    url = "https://git.hrfee.pw/hrfee/waybar-mpris.git";
    rev = "485ec0ec0af80a0d63c10e94aebfc59b16aab46b";
    sha256 = "BjLxWnDNsR2ZnNklNiKzi1DeoPpaZsRdKbVSwNwYhJ4=";
  };

  vendorSha256 = "85jFSAOfNMihv710LtfETmkKRqcdRuFCHVuPkW94X/Y=";

  meta = with lib; {
    description = "MPRIS2 waybar component";
    homepage = "https://git.hrfee.pw/hrfee/waybar-mpris";
    changelog = "https://git.hrfee.pw/hrfee/waybar-mpris";
    license = licenses.mit;
    maintainers = [ "pikpok" ];
  };
}
