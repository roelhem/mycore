{ config, lib, ... }:

let

  inherit (lib)
    mkIf
    mkEnableOption
    mkDefault
    ;

  cfg = config.mycore.languages.python;

in

{
  options.mycore.languages.python = {
    enable = mkEnableOption "Python language support";
  };

  config = mkIf cfg.enable {
    mycore.everyDevShell.python.enable = mkDefault true;

    treefmt.programs.black.enable = mkDefault true;
  };
}
