{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [vscode];

  fonts = let
    fnts = with pkgs; [fira-code];
  in
    # TODO: hack to get around waiting for nix-darwin#870
    ({fontDir.enable = true;}
      // lib.mkIf pkgs.stdenv.isLinux {packages = fnts;}
      // lib.mkIf pkgs.stdenv.isDarwin {fonts = fnts;});
}
