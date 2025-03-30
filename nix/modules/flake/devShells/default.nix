{
  config,
  lib,
  flake-parts-lib,
  ...
}:

let

  inherit (lib) mkOption types mkDefault;

  inherit (flake-parts-lib) mkPerSystemOption;

in

{
  options.perSystem = mkPerSystemOption (
    { pkgs, config, ... }:
    let
      cfg = config.mycore;

      enabledDevShells = lib.filterAttrs (name: value: value.enable) cfg.devShells;
    in
    {
      options.mycore = {
        everyDevShell = mkOption {
          type = types.deferredModuleWith {
            staticModules = [
              {
                _module.args = {
                  inherit pkgs;
                  systemConfig = config;
                };
              }
              {
                options.enable = mkOption {
                  type = types.bool;
                  default = true;
                };
              }
              ./devShell.nix
            ];
          };
          default = { };
        };

        devShells = mkOption {
          type = types.lazyAttrsOf (types.submoduleWith { modules = [ cfg.everyDevShell ]; });
          default = { };
        };
      };

      config = {
        devShells = builtins.mapAttrs (name: value: mkDefault value.finalPackage) enabledDevShells;
      };
    }
  );
}
