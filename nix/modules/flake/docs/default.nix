{
  lib,
  flake-parts-lib,
  ...
}:

let

  inherit (lib)
    mkOption
    types
    ;

  inherit (flake-parts-lib) mkPerSystemOption;

in

{
  options.perSystem = mkPerSystemOption (
    { pkgs, config, ... }:

    let
      enabledDocs = lib.filterAttrs (name: doc: doc.enable) config.docs;
    in
    {
      options = {
        everyDoc = mkOption {
          type = types.deferredModuleWith {
            staticModules = [
              { _module.args = { inherit pkgs; }; }
              ./doc.nix
            ];
          };
          default = { };
        };

        docs = mkOption {
          type = types.lazyAttrsOf (
            types.submoduleWith {
              modules = [ config.everyDoc ];
            }
          );
          default = { };
          description = "Documentation";
        };
      };

      config = {
        packages.docs = pkgs.runCommand "docs" { } ''
          mkdir $out

          ${lib.concatMapAttrsStringSep "\n" (name: doc: "ln -s ${doc.package} $out/${name}") enabledDocs}
        '';
      };
    }
  );
}
