{
  config,
  lib,
  pkgs,
  ...
}:

let

  inherit (lib) mkOption types;

  enabledSections = lib.filterAttrs (n: v: v.enable) config.sections;

in

{
  options = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    package = mkOption {
      internal = true;
      type = types.package;
      description = "The generated doc package.";
    };

    everySection = mkOption {
      type = types.deferredModuleWith {
        staticModules = [
          { _module.args = { inherit pkgs; }; }
          ./section.nix
        ];
      };
      description = "Shared configuration of the sections.";
      default = { };
    };

    sections = mkOption {
      type = types.attrsOf (
        types.submoduleWith {
          modules = [ config.everySection ];
        }
      );
      description = "The sections that will be displayed in the documentation.";
      default = { };
    };

    shell = mkOption {
      internal = true;
      type = types.package;
      description = "The devShell that can be used to interact with this doc.";
    };
  };

  config = {

    package = pkgs.runCommand "doc" { } ''
      mkdir $out

      ${lib.concatMapAttrsStringSep "\n" (
        name: sec: "ln -s ${sec.rendered.finalPackage} $out/${name}"
      ) enabledSections}
    '';
  };
}
