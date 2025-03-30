{
  config,
  lib,
  moduleType,
  ...
}:

let

  inherit (lib)
    mkOption
    types
    mkIf
    mkDefault
    ;

  cfg = config.mycore.defaults;

in

{
  options.mycore.defaults = {
    enable = mkOption {
      type = types.bool;
      description = "Use mycore configuration defaults.";
      default = true;
    };
  };

  config = mkIf cfg.enable {

    systems = mkDefault [
      "x86_64-linux"
      "aarch64-linux"
      "i686-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    mycore.autowire.enable = mkDefault true;

    perSystem =
      { pkgs, lib, ... }:
      {
        treefmt = {
          projectRootFile = mkDefault "flake.nix";

          programs.nixfmt.enable = mkDefault (
            pkgs.lib.meta.availableOn pkgs.stdenv.buildPlatform pkgs.nixfmt-rfc-style.compiler
          );
          programs.nixfmt.package = mkDefault pkgs.nixfmt-rfc-style;

          programs.just.enable = mkDefault true;
        };

        mycore = {
          devShells.default.just.enable = mkDefault true;
        };

        everyDoc = {
          sections.flake.nixModuleOptions.options = mkDefault (moduleType.getSubOptions [ ]);
        };

        docs.default.sections.flake.nixModuleOptions.enable = mkDefault true;
      };
  };
}
