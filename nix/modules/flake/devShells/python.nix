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
    optional
    ;

  cfg = config.python;

in

{
  options.python = {
    enable = mkEnableOption "Python language support";

    package = mkOption {
      type = types.package;
      default = pkgs.python3;
    };

    poetry = {
      enable = mkEnableOption "Poetry";

      package = mkOption {
        type = types.package;
        default = pkgs.poetry;
      };
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ] ++ optional cfg.poetry.enable cfg.poetry.package;

    shellHook = ''
      echo "  python (${cfg.package.name})"
      ${if cfg.poetry.enable then "echo \"  poetry (${cfg.poetry.package.name})\"" else ""}
    '';
  };
}
