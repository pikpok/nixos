{inputs, ...}: {
  home-manager.users.pikpok.imports = [
    inputs.self.homeManagerModules.pikpok.desktopLinux
  ];
}
