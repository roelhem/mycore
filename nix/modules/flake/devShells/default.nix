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
    in
    {
      options.mycore = {
        everyDevShell = mkOption {
          type = types.deferredModuleWith {
            staticModules = [
              { _module.args = { inherit pkgs; }; }
              ./devShell.nix
              ./just.nix
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
        devShells = builtins.mapAttrs (name: value: mkDefault value.finalPackage) cfg.devShells;
      };
    }
  );
}
