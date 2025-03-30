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
  options = {
    env = mkOption {
      default = { };
      description = ''
        An attribute set to control environment variables in the shell environment.

        If the value of an attribute is `null`, the variable of that attribute's name is `unset`.  Otherwise the variable of the attribute name is set to the attribute's value.  Integer, path, and derivation values are converted to strings.  The boolean true value is converted to the string `"1"`, and the boolean false value is converted to the empty string `""`.
      '';
      example = lib.literalExpression ''
        {
          VARIABLE_NAME = "variable value";
          UNSET = null;
          EMPTY = false;
          TWO = 2;
          PATH_TO_NIX_STORE_FILE = ./my-file;
          COWSAY = pkgs.cowsay
        }
      '';
      type = types.attrsOf (
        types.nullOr (
          types.oneOf [
            types.bool
            types.int
            types.package
            types.path
            types.str
          ]
        )
      );
    };

    envSetup = mkOption {
      type = types.lines;
      default = "";
    };

    projectRoot = {
      fallback = mkOption {
        type = types.lines;
        default = "";
      };
    };

    finalEnv = mkOption {
      readOnly = true;
      internal = true;
      # mkShell.env values can be derivations, strings, booleans or integers.
      # path and null values are separated for special handling.
      type = types.attrsOf (
        types.oneOf [
          types.bool
          types.int
          types.str
          types.package
        ]
      );
      default =
        let
          inherit (builtins) isPath toString;
          inherit (lib.attrsets) filterAttrs mapAttrs;
          simpleEnv = filterAttrs (_: v: !(v == null || isPath v)) config.env;
          pathEnv = filterAttrs (_: isPath) config.env;
        in
        simpleEnv // mapAttrs (_: toString) pathEnv;
    };
  };
  config =
    let
      inherit (builtins) attrNames concatStringsSep;
      inherit (lib.attrsets) filterAttrs;
      envVarsToUnset = attrNames (filterAttrs (_: v: v == null) config.env);

      envSetupHook = pkgs.writeText "${config.name}-env-setup-hook.sh" ''
        if [[ -n ''${IN_NIX_SHELL:-} || ''${DIRENV_IN_ENVRC:-} = 1 ]]; then
           PRJ_ROOT=$PWD
        elif [[ -z "''${PRJ_ROOT:-}" ]]; then
           ${config.projectRoot.fallback}

           if [[ -z "''${PRJ_ROOT:-}" ]]; then
             echo "ERROR: please set the PRJ_ROOT env var to point to the project root" >&2
             return 1
           fi
        fi

        export PRJ_ROOT
        export PRJ_DATA_DIR="$PRJ_ROOT/.data"

        ${config.envSetup}

        ${if envVarsToUnset == [ ] then "" else "unset ${concatStringsSep " " envVarsToUnset}"}
      '';

    in
    {
      shellHook = "source ${envSetupHook}";
    };
}
