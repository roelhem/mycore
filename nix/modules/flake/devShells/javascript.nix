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

  cfg = config.javascript;

  nodejs = cfg.package;
  npkgs = nodejs.pkgs;

in

{
  options.javascript = {
    enable = mkEnableOption "JavaScript language support";

    package = mkOption {
      type = types.package;
      default = pkgs.nodejs;
    };

    bun = {
      enable = mkEnableOption "bun";

      package = mkOption {
        type = types.package;
        default = pkgs.bun;
      };
    };

    pnpm = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };

      package = mkOption {
        type = types.package;
        default = npkgs.pnpm;
      };
    };

    yarn = {
      enable = mkEnableOption "yarn";
      package = mkOption {
        type = types.package;
        default = npkgs.yarn;
      };
    };

  };

  config = mkIf cfg.enable {

    packages =
      [ nodejs ]
      ++ optional cfg.bun.enable cfg.bun.package
      ++ optional cfg.pnpm.enable cfg.pnpm.package
      ++ optional cfg.yarn.enable cfg.yarn.package;

    shellHook =
      let
        tools = lib.filterAttrs (name: value: value.enable) {
          bun = cfg.bun;
          pnpm = cfg.pnpm;
          yarn = cfg.yarn;
        };
      in
      ''
        echo "  node (${nodejs.name})"
        ${lib.concatMapAttrsStringSep "\n" (
          name: value: "echo \"  ${name} (${value.package.name})\""
        ) tools}
      '';

  };
}
