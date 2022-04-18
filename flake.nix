{
  inputs = {
    nixpkgs = {url = "github:nixos/nixpkgs/nixos-unstable";};

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";

    pinebook-pro = {
      url = "github:samueldr/wip-pinebook-pro";
      flake = false;
    };
    pinebook-pro.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nur,
    darwin,
    ...
  } @ inputs: {
    nixosConfigurations.pikpok-pbp = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        ./hosts/pbp
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
