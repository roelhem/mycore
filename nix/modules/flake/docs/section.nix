{
  config,
  lib,
  pkgs,
  ...
}:

let

  inherit (lib) mkOption types;

in

{
  imports = [ ./moduleOptions.nix ];

  options = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };

    title = mkOption {
      type = types.str;
      description = ''
        Title of this documentation section.
      '';
      default = "";
    };

    menu = {
      title = mkOption {
        type = types.str;
        description = ''
          Title of the menu entry for this section.
        '';
        default = config.title;
      };

      visible = mkOption {
        type = types.bool;
        description = ''
          Whether to add this section to the navigation menu.
        '';
        default = false;
      };
    };

    rendered = {
      markdown = {
        file = mkOption {
          type = types.path;
          description = "Path to the rendered markdown documentation file.";
        };
      };

      json = {
        file = mkOption {
          type = types.path;
        };
      };

      adoc = {
        file = mkOption { type = types.path; };
      };

      finalPackage = mkOption {
        type = types.package;
        description = ''
          A package containing the collection of generated documentation pages.
        '';
        readOnly = true;
      };
    };
  };

  config = {
    rendered.finalPackage =
      pkgs.runCommand ""
        {
          passthru = {
            files.markdown = config.markdown.file;
          };
        }
        ''
          mkdir $out

          ln -s ${config.rendered.markdown.file} $out/nix-module-options.md
          ln -s ${config.rendered.json.file} $out/nix-module-options.json
          ln -s ${config.rendered.adoc.file} $out/nix-module-options.adoc
        '';
  };
}
