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

  cfg = config.go;

in

{
  options.go = {
    enable = mkEnableOption "Go language support";

    package = mkOption {
      type = types.package;
      default = pkgs.go;
      description = "The go package to use.";
    };
  };

  config = mkIf cfg.enable {
    packages = [ cfg.package ];

    shellHook = "echo \" 󰟓 go (${cfg.package.name})\"";
  };
}
