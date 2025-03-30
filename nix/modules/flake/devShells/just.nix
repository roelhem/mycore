{
  config,
  lib,
  pkgs,
  ...
}:

let

  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    types
    ;

  cfg = config.just;

in

{
  options.just = {
    enable = mkEnableOption "`just` support";

    list.enable = mkOption {
      type = types.bool;
      default = true;
    };

    list.heading = mkOption {
      type = types.str;
      default = "Available just recipes:\n";
    };

    list.submodules = mkOption {
      type = types.bool;
      default = false;
    };

  };

  config = mkIf cfg.enable {

    packages = with pkgs; [ just ];

    shellHook = mkIf cfg.list.enable ''
      echo;
      just --list --list-heading "${cfg.list.heading}" --list-prefix "$(printf '\e[0;90mjust \e[0m')" ${
        if cfg.list.submodules then "--list-submodules" else ""
      };
      echo;
    '';

  };
}
