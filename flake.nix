{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-m1 = {
      url = "github:tpwrules/nixos-m1/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    actual-nix = {
      url = "https://git.xeno.science/xenofem/actual-nix/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nur,
    darwin,
    sops-nix,
    actual-nix,
    ...
  } @ inputs: let
    systems = {
      x86_64-linux = "x86_64-linux";
      aarch64-linux = "aarch64-linux";
      aarch64-darwin = "aarch64-darwin";
    };

    mkSystem = {
      system,
      modules,
    }:
      (
        if builtins.match ".*-darwin" system != null
        then darwin.lib.darwinSystem
        else nixpkgs.lib.nixosSystem
      ) {
        inherit system modules;
        specialArgs = {inherit inputs;};
      };

    commonModules = [
      {
        nixpkgs.overlays = [nur.overlays.default];
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
    ];

    mkCommonModules = extraModules: extraModules ++ commonModules;
  in {
    nixosConfigurations = {
      domino = mkSystem {
        system = systems.x86_64-linux;
        modules = mkCommonModules [
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          actual-nix.nixosModules.default
          ./hosts/domino
        ];
      };

      pikpok-mbp-asahi = mkSystem {
        system = systems.aarch64-linux;
        modules = mkCommonModules [
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          ./hosts/mbp-asahi
        ];
      };
    };

    darwinConfigurations."pikpok-mbp" = mkSystem {
      system = systems.aarch64-darwin;
      modules = mkCommonModules [
        home-manager.darwinModules.home-manager
        ./hosts/mbp
      ];
    };
  };
}
