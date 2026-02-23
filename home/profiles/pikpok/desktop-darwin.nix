{...}: {
  imports = [
    ./common.nix
    ../../modules/shell.nix
    ../../modules/firefox.nix
    ../../modules/darwin-homebrew-overrides.nix
  ];
}
