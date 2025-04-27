{
  self,
  config,
  lib,
  mycore-lib,
  ...
}:

let

  inherit (lib)
    mkIf
    mkOption
    mkDefault
    mkEnableOption
    types
    composeExtensions
    ;

  nixFiles = import ../../lib/nix-files.nix { inherit lib; };

  inherit (nixFiles) zipDirsNixFiles mapAttrsMaybe;

  cfg = config.mycore.autowire;

  defaultPathsFromSubPaths =
    subPaths:
    builtins.concatMap (prefix: builtins.map (subPath: "${prefix}/${subPath}") subPaths) cfg.paths;

  autowireConfigType =
    module:
    types.submoduleWith {
      modules = [
        (
          { config, ... }:
          {
            options = {
              enable = mkEnableOption "autowiring";

              subPaths = mkOption {
                type = types.listOf types.str;
                description = "The sub-paths of the root autowire paths that will be searched for nix files to autowire.";
                default = [ ];
              };

              paths = mkOption {
                type = types.listOf types.path;
                description = "The paths that will be searched for nix files to autowire.";
                default = defaultPathsFromSubPaths config.subPaths;
              };

              itemFromNixFiles = mkOption {
                default = (name: files: if builtins.length files == 0 then null else files);
                description = "Function `string -> [string] -> null | T` that converts a name and a list of files to the result value.";
              };

              files = mkOption {
                type = types.attrsOf (types.listOf types.str);
                description = "The nix source files to use per autowire item.";
              };

              defaultValue = mkOption {
                type = types.lazyAttrsOf types.anything;
                visible = false;
                default = { };
              };

              discoveredValue = mkOption {
                type = types.attrsOf types.anything;
                visible = false;
                readOnly = true;
              };

              value = mkOption {
                type = types.lazyAttrsOf types.anything;
                visible = false;
              };
            };

            config = {
              enable = mkDefault true;
              files = zipDirsNixFiles config.paths;
              discoveredValue = mapAttrsMaybe (
                name: files: lib.nameValuePair name (config.itemFromNixFiles name files)
              ) config.files;
              value = config.defaultValue // config.discoveredValue;
            };
          }
        )
        module
      ];
    };

  autoDefaultModule =
    { config, ... }:
    {
      options.autoDefaultModule = mkOption {
        type = types.bool;
        default = true;
      };

      config.itemFromNixFiles =
        name:
        (zom {
          one = file: import file;
          many =
            files:
            builtins.trace files {
              imports = files;
            };
        });

      config.defaultValue = mkIf config.autoDefaultModule {
        default = {
          imports = builtins.attrValues config.discoveredValue;
        };
      };
    };

  mkAutowireOption =
    name: module:
    mkOption {
      type = autowireConfigType module;
      description = "Autowire configuration for the `${name}` flake attr.";
      default = { };
    };

  mkAutowireOptions = builtins.mapAttrs mkAutowireOption;

  importExtension =
    file:
    let
      fn = if builtins.isFunction file then file else import file;
    in
    fn mycore-lib.specialArgsFor.common;

  zom =
    {
      zero ? null,
      one ? file: file,
      many ? one,
    }:
    files:
    if builtins.length files == 0 then
      zero
    else if builtins.length files == 1 then
      one (builtins.elemAt files 0)
    else
      many files;

in
{
  options.mycore.autowire = {
    enable = mkEnableOption "Enable autowire";

    paths = mkOption {
      type = types.listOf types.path;
      default = [ "${self}/nix" ];
      description = "The root search paths from which the default autowiring paths are derived.";
    };

    autoDefaultModules = {
      enable = mkEnableOption "Enable automatically generated default modules.";
    };

    flake = mkAutowireOptions {
      nixosConfigurations =
        { config, ... }:
        {
          options.useHomeManager = mkOption {
            type = types.bool;
            default = true;
            description = "Use home manager for autowired nixosConfigurations.";
          };

          config.subPaths = mkDefault [
            "configurations/nixos"
          ];

          config.itemFromNixFiles =
            name: (zom { one = mycore-lib.mkNixosSystem { home-manager = config.useHomeManager; }; });
        };

      nixosModules = {
        imports = [ autoDefaultModule ];
        options.useHomeManager = mkOption {
          type = types.bool;
          default = true;
          description = "Use home manager for autowired nixosConfigurations.";
        };
        config.subPaths = mkDefault [
          "modules/common"
          "modules/nixos"
        ];
      };

      darwinConfigurations =
        { config, ... }:
        {
          options.useHomeManager = mkOption {
            type = types.bool;
            default = true;
            description = "Use home manager for autowired darwinConfigurations.";
          };
          config.subPaths = mkDefault [
            "configurations/darwin"
          ];
          config.itemFromNixFiles =
            name:
            (zom {
              one = mycore-lib.mkDarwinSystem { home-manager = config.useHomeManager; };
            });
        };

      darwinModules = {
        imports = [ autoDefaultModule ];
        config.subPaths = mkDefault [
          "modules/common"
          "modules/darwin"
        ];
      };

      homeModules = {
        imports = [ autoDefaultModule ];
        config.subPaths = mkDefault [
          "modules/home"
          "modules/home-manager"
        ];
      };

      emacsModules = {
        imports = [ autoDefaultModule ];
        config.subPaths = mkDefault [
          "modules/emacs"
        ];
      };

      flakeModules = {
        imports = [ autoDefaultModule ];
        config.subPaths = mkDefault [
          "modules/flake"
          "modules/flake-parts"
        ];
      };

      overlays = {
        config.subPaths = mkDefault [
          "overlays"
        ];

        config.itemFromNixFiles =
          name:
          (zom {
            one = importExtension;
            many = lib.foldr (file: next: composeExtensions (importExtension file) next) (final: prev: { });
          });
      };
    };
  };

  config = mkIf cfg.enable {
    flake = builtins.mapAttrs (name: args: mkIf args.enable (mkDefault args.value)) cfg.flake;
  };
}
