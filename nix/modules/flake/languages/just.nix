{
  config,
  lib,
  ...
}:

let

  inherit (lib)
    mkIf
    mkEnableOption
    mkDefault
    ;

  cfg = config.mycore.languages.just;

in

{
  options.mycore.languages.just = {
    enable = mkEnableOption "Just language support";
  };

  config = mkIf cfg.enable {
    mycore.devShells.default.just.enable = mkDefault true;

    treefmt.programs.just.enable = mkDefault true;
  };
}
