final: super:

let inherit (final) callPackage;
in { waybar-mpris = callPackage ./waybar-mpris.nix { }; }
