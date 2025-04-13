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
    filterAttrs
    concatMapAttrsStringSep
    mapAttrsToList
    ;

  cfg = config.haskell;

  hpkgs = cfg.packages;

  mkHaskellToolOption =
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
      description = "Configure the `${name}` haskell tool.";
      default = { };
    };

  tools = {
    ghc = {
      package = hpkgs.ghc;
      enable = true;
    };
    cabal = {
      package = hpkgs.cabal-install;
      enable = true;
    };
    cabal2nix = {
      package = hpkgs.cabal2nix;
      enable = cfg.tools.cabal.enable;
    };
    stack = {
      package = hpkgs.stack;
      enable = true;
    };
    haskell-language-server = {
      package = hpkgs.haskell-language-server;
      enable = false;
    };
    hlint = {
      package = hpkgs.hlint;
      enable = true;
    };
  };

  enabledTools = filterAttrs (name: value: value.enable) cfg.tools;

in

{
  options.haskell = {
    enable = mkEnableOption "Haskell support";

    compiler = mkOption {
      type = types.nullOr (types.enum (builtins.attrNames pkgs.haskell.compiler));
      default = null;
    };

    packages = mkOption {
      type = types.attrsOf types.package;
      description = "The haskell package set that is used to build the dev shell.";
      default =
        if (cfg.compiler == null) then pkgs.haskellPackages else pkgs.haskell.packages.${cfg.compiler};
    };

    tools = lib.mapAttrs mkHaskellToolOption tools;
  };

  config = mkIf cfg.enable {

    packages = mapAttrsToList (name: tool: tool.package) enabledTools;

    shellHook = ''
      ${concatMapAttrsStringSep "\n" (
        name: value: "echo \"  ${name} (${value.package.name})\";"
      ) enabledTools}
    '';

  };
}
