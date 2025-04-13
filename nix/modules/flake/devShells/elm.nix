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
    types
    filterAttrs
    mkIf
    mapAttrs
    mapAttrsToList
    concatMapAttrsStringSep
    ;

  cfg = config.elm;
  epkgs = cfg.packages;

  mkElmToolOption =
    name:
    {
      package,
      enable ? false,
      modules ? [ ],
    }:
    mkOption {
      type = types.submoduleWith {
        modules = [
          {
            options.enable = mkOption {
              type = types.bool;
              description = "Whether to include `${name}` in the devshell.";
              default = enable;
            };

            options.package = mkOption {
              type = types.package;
              description = "The `${name}` package to use.";
              default = package;
            };
          }
        ] ++ modules;
      };
      description = "Configure the `${name}` elm tool.";
      default = { };
    };

  tools = {
    elm = {
      package = epkgs.elm;
      enable = true;
    };
    elm2nix = {
      package = pkgs.elm2nix;
      enable = true;
    };
    elm-language-server = {
      package = epkgs.elm-language-server;
      enable = false;
    };
  };

  enabledTools = filterAttrs (name: value: value.enable) cfg.tools;

in

{
  options.elm = {
    enable = mkEnableOption "Elm support";

    packages = mkOption {
      type = types.attrsOf types.anything;
      description = "The elm package set to use.";
      default = pkgs.elmPackages;
    };

    tools = mapAttrs mkElmToolOption tools;
  };

  config = mkIf cfg.enable {

    packages = mapAttrsToList (name: tool: tool.package) enabledTools;

    shellHook = ''
      ${concatMapAttrsStringSep "\n" (
        name: value: "echo \"  ${name} (${value.package.name})\";"
      ) enabledTools}
    '';

  };
}
