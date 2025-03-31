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
    mkOption
    types
    ;

  cfg = config.mycore.languages.haskell;

in

{
  options.mycore.languages.haskell = {
    enable = mkEnableOption "Haskell language support";

    formatter = mkOption {
      type = types.enum [
        "stylish-haskell"
        "fourmolu"
        "ormolu"
      ];
      description = "The haskell formatter to use for this project.";
      default = "stylish-haskell";
    };
  };

  config = mkIf cfg.enable {
    mycore.everyDevShell.haskell.enable = mkDefault true;

    treefmt.programs.cabal-fmt.enable = mkDefault true;
    treefmt.programs.stylish-haskell.enable = mkDefault (cfg.formatter == "stylish-haskell");
    treefmt.programs.fourmolu.enable = mkDefault (cfg.formatter == "fourmolu");
    treefmt.programs.ormolu.enable = mkDefault (cfg.formatter == "ormolu");
  };
}
