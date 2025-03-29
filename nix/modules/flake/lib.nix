{
  self,
  inputs,
  config,
  lib,
  ...
}:

let

  inherit (lib) mkOption mkDefault;

  /**
    Creates a new "library option", which is just an attrSet of helper functions
    that is embedded into nix-style configuration modules.
  */
  mkLibraryOption =
    lib:
    mkOption {
      readOnly = true;
      visible = false;
      default = lib;
    };

  specialArgsFor = rec {
    common = {
      inherit mycore-lib;
      flake = { inherit self inputs config; };
    };

    nixos = common;

    darwin = common // {
      rosettaPkgs = import inputs.nixpkgs { system = "x86_64-darwin"; };
    };
  };

  homeModules = {
    common =
      { config, pkgs, ... }:
      {
      };
  };

  nixosModules = {
    home-manager = {
      imports = [
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = specialArgsFor.nixos;
          home-manager.sharedModules = [
            (
              { config, ... }:
              {
                home.homeDirectory = mkDefault "/home/${config.home.username}";
              }
            )
            homeModules.common
          ];
        }
      ];
    };
  };

  darwinModules = {
    home-manager = {
      imports = [
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = specialArgsFor.darwin;
          home-manager.sharedModules = [
            (
              { config, ... }:
              {
                home.homeDirectory = mkDefault "/Users/${config.home.username}";
              }
            )
            homeModules.common
          ];
        }
      ];
    };
  };

  mycore-lib = {
    inherit mkLibraryOption specialArgsFor;

    mkNixosSystem =
      {
        home-manager ? false,
      }:
      module:
      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = specialArgsFor.nixos;
        modules = [ module ] ++ lib.optional home-manager nixosModules.home-manager;
      };

    mkDarwinSystem =
      {
        home-manager ? false,
      }:
      module:
      inputs.nix-darwin.lib.darwinSystem {
        specialArgs = specialArgsFor.darwin;
        modules = [ module ] ++ lib.optional home-manager darwinModules.home-manager;
      };
  };

in

{
  options.mycore.lib = mkLibraryOption mycore-lib;

  config._module.args = { inherit mycore-lib; };
}
