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

    nix-rosetta-builder = {
      url = "github:cpick/nix-rosetta-builder";
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

    teslamate = {
      url = "github:teslamate-org/teslamate/v2.2.0";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ssh-keys = {
      url = "https://github.com/pikpok.keys";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nur,
    darwin,
    nix-rosetta-builder,
    sops-nix,
    teslamate,
    disko,
    ...
  } @ inputs: let
    primaryUser = "pikpok";

    systems = {
      x86_64-linux = "x86_64-linux";
      aarch64-linux = "aarch64-linux";
      aarch64-darwin = "aarch64-darwin";
    };

    homeDirectories = {
      linux = "/home/${primaryUser}";
      darwin = "/Users/${primaryUser}";
    };

    defaultHomeDirectoryForSystem = system:
      if builtins.match ".*-darwin" system != null
      then homeDirectories.darwin
      else homeDirectories.linux;

    mkPkgs = system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [nur.overlays.default];
      };

    homeManagerModules = {
      pikpok = {
        common = import ./home/profiles/pikpok/common.nix;
        minimalLinux = import ./home/profiles/pikpok/minimal-linux.nix;
        serverLinux = import ./home/profiles/pikpok/server-linux.nix;
        desktopLinux = import ./home/profiles/pikpok/desktop-linux.nix;
        desktopDarwin = import ./home/profiles/pikpok/desktop-darwin.nix;
      };
    };

    mkHome = {
      system,
      modules,
      username ? primaryUser,
      homeDirectory ? defaultHomeDirectoryForSystem system,
    }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs system;
        modules =
          [
            {
              home = {
                inherit username homeDirectory;
              };
            }
          ]
          ++ modules;
        extraSpecialArgs = {inherit inputs;};
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
        home-manager.extraSpecialArgs = {inherit inputs;};
      }
    ];

    mkCommonModules = extraModules: extraModules ++ commonModules;

    homeTargets = {
      desktop-linux-aarch64 = {
        system = systems.aarch64-linux;
        module = homeManagerModules.pikpok.desktopLinux;
      };

      desktop-linux-x86_64 = {
        system = systems.x86_64-linux;
        module = homeManagerModules.pikpok.desktopLinux;
      };

      server-linux-x86_64 = {
        system = systems.x86_64-linux;
        module = homeManagerModules.pikpok.serverLinux;
      };

      desktop-darwin-aarch64 = {
        system = systems.aarch64-darwin;
        module = homeManagerModules.pikpok.desktopDarwin;
      };
    };
  in {
    inherit homeManagerModules;

    homeConfigurations = builtins.mapAttrs (_name: target:
      mkHome {
        inherit (target) system;
        modules = [target.module];
      })
    homeTargets;

    nixosConfigurations = {
      domino = mkSystem {
        system = systems.x86_64-linux;
        modules = mkCommonModules [
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          teslamate.nixosModules.default
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

      torpeda = mkSystem {
        system = systems.aarch64-linux;
        modules = mkCommonModules [
          home-manager.nixosModules.home-manager
          disko.nixosModules.disko
          ./hosts/torpeda
        ];
      };
    };

    darwinConfigurations."pikpok-mbp" = mkSystem {
      system = systems.aarch64-darwin;
      modules = mkCommonModules [
        nix-rosetta-builder.darwinModules.default
        home-manager.darwinModules.home-manager
        ./hosts/mbp
      ];
    };
  };
}
