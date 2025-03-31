{
  config,
  lib,
  stable,
  ...
}:

let

  inherit (lib)
    mkEnableOption
    mkIf
    mkDefault
    ;

  cfg = config.mycore.languages.elm;

in

{
  options.mycore.languages.elm = {
    enable = mkEnableOption "Elm language support";
  };

  config = mkIf cfg.enable {
    mycore.everyDevShell.elm.enable = mkDefault true;

    treefmt.programs.elm-format.enable = mkDefault true;
    treefmt.programs.elm-format.package = mkDefault stable.elmPackages.elm-format;
  };
}
