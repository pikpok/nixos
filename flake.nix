{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixos-m1.url = "github:tpwrules/nixos-m1/main";
    nixos-m1.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nur,
    darwin,
    nixos-hardware,
    sops-nix,
    ...
  } @ inputs: {
    # nixosConfigurations.pikpok-pbp = nixpkgs.lib.nixosSystem {
    #   system = "aarch64-linux";
    #   modules = [
    #     home-manager.nixosModules.home-manager
    #     nixos-hardware.nixosModules.pine64-pinebook-pro
    #     ./hosts/pbp
    #     {
    #       nixpkgs.overlays = [nur.overlay];
    #       home-manager.useGlobalPkgs = true;
    #       home-manager.useUserPackages = true;
    #     }
    #   ];
    #   specialArgs = {inherit inputs;};
    # };

    nixosConfigurations.pikpok-mbp-asahi = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        ./hosts/mbp-asahi
        {
          nixpkgs.overlays = [nur.overlay];
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
      ];
      specialArgs = {inherit inputs;};
    };

    nixosConfigurations.raspberrypi = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        ./hosts/raspberrypi
        {
          nixpkgs.overlays = [nur.overlay];
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
      ];
      specialArgs = {inherit inputs;};
    };

    darwinConfigurations."pikpok-mbp" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        home-manager.darwinModules.home-manager
        ./hosts/mbp
        {
          nixpkgs.overlays = [nur.overlay];
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
      ];
      specialArgs = {inherit inputs;};
    };
  };
}
