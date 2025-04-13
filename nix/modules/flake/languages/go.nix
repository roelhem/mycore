{
  config,
  lib,
  ...
}:

let

  inherit (lib) mkEnableOption mkDefault mkIf;

  cfg = config.mycore.languages.go;

in

{
  options.mycore.languages.go = {
    enable = mkEnableOption "Go language support";
  };

  config = mkIf cfg.enable {
    mycore.everyDevShell.go.enable = mkDefault true;

    treefmt.programs.gofmt.enable = mkDefault true;
  };
}
