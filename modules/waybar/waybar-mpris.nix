{ lib, stdenv, buildGoModule, fetchgit }:

buildGoModule rec {
  pname = "waybar-mpris";
  version = "0.1.0";

  src = fetchgit {
    url = "https://git.hrfee.pw/hrfee/waybar-mpris.git";
    rev = "4b71fa248ad07e23a62d1d5811e163113e1baab1";
    sha256 = "ACfK3Ce6C07e851++ZeWQFHJlpoXN8Nh58+1fiVbrwk=";
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