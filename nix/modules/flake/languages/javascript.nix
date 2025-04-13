{ config, lib, ... }:

let

  inherit (lib)
    mkIf
    mkEnableOption
    mkDefault
    ;

  cfg = config.mycore.languages.javascript;

in

{
  options.mycore.languages.javascript = {
    enable = mkEnableOption "JavaScript language support";
  };

  config = mkIf cfg.enable {
    mycore.everyDevShell.javascript.enable = mkDefault true;

    treefmt.programs.prettier.enable = mkDefault true;
  };
}
