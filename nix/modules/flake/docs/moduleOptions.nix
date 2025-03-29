{
  config,
  lib,
  pkgs,
  ...
}:

let

  inherit (lib) mkOption mkEnableOption types;

  cfg = config.nixModuleOptions;

in

{
  options.nixModuleOptions = {
    enable = mkEnableOption "nixModuleOptions documentation";

    options = mkOption {
      type = types.raw;
      description = "The options for which you want to generate documentation.";
    };

    optionIdPrefix = mkOption {
      type = types.str;
      description = "String to prefix to the option XML/HTML id attributes.";
      default = "opt-";
    };

    revision = mkOption {
      type = types.str;
      description = "Specify revision for the options";
      default = "";
    };

    _nixosOptionsDoc = mkOption {
      internal = true;
    };

    warningsAreErrors = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether the building of this documentation section should fail if some warning occurred.
      '';
    };
  };

  config = {
    nixModuleOptions = {
      _nixosOptionsDoc = pkgs.nixosOptionsDoc {
        inherit (cfg)
          options
          warningsAreErrors
          revision
          optionIdPrefix
          ;
      };
    };

    rendered.markdown.file = cfg._nixosOptionsDoc.optionsCommonMark;
    rendered.json.file = "${cfg._nixosOptionsDoc.optionsJSON}/share/doc/nixos/options.json";
    rendered.adoc.file = cfg._nixosOptionsDoc.optionsAsciiDoc;
  };
}
