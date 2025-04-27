let
  flake = builtins.getFlake (toString ./.);

  nixpkgs = import <nixpkgs> { };

  lib = nixpkgs.lib;

  system = builtins.currentSystem;

  packages = flake.packages.${system};
in
{
  inherit flake packages lib;
  pkgs = nixpkgs;
  overlays = flake.overlays;
  apps = flake.apps.${system};
  devShells = flake.devShells.${system};
  legacyPackages = flake.legacyPackages.${system};
  formatter = flake.formatter.${system};
  nixosConfigurations = flake.nixosConfigurations;
  nixosModules = flake.nixosModules;
}
// builtins
// lib
