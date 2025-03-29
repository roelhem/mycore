{ lib, config, ... }:

let

  inherit (lib)
    mkOption
    mkDefault
    types
    mkIf
    ;

  cfg = config.mycore;

in

{
  options.mycore = {
    useMyDefaults = mkOption {
      type = types.bool;
      default = true;
      description = "Use my default overrides";
    };
  };

  config = mkIf cfg.useMyDefaults {
    nix.settings = {
      # Use all CPU cores by default.
      max-jobs = mkDefault "auto";
      # Enable nix flakes by default.
      experimental-features = mkDefault "nix-command flakes";
      # Accept flake configs by default.
      accept-flake-config = mkDefault true;
    };
  };
}
