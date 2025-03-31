{
  config,
  lib,
  pkgs,
  name,
  ...
}:

let

  inherit (lib) mkOption types;
in

{
  imports = [
    ./env.nix
    ./packages.nix
    ./pre-commit.nix
    ./just.nix
    ./haskell.nix
    ./elm.nix
  ];

  options = {
    name = mkOption {
      type = types.str;
      default = "devShell-${name}";
    };

    stdenv = mkOption {
      default = pkgs.stdenv;
      defaultText = lib.literalExpression "pkgs.stdenv";
      example = lib.literalExpression "pkgs.stdenvNoCC";
      description = "The standard environment from which the shell derivation will be created.";
      type = types.package;
    };

    finalPackage = mkOption {
      description = "The shell derivation resulting from passing the evaluated configuration to mkDerivation.";
      readOnly = true;
      type = types.package;
    };
    shellHook = mkOption {
      default = "";
      description = "Bash code evaluated when the shell environment starts.";
      type = types.lines;
    };
    additionalArguments = mkOption {
      default = { };
      description = "Arbitrary additional arguments passed to mkDerivation.";
      type = types.attrsOf types.anything;
    };
  };

  config = {
    finalPackage = config.stdenv.mkDerivation (
      lib.recursiveUpdate {
        inherit (config)
          buildInputs
          name
          propagatedBuildInputs
          propagatedNativeBuildInputs
          shellHook
          ;
        # Using the identical buildPhase to mkShell lets many
        # mkShell->make-shell migrations be bit-identical and re-use the
        # same cache.
        inherit (pkgs.mkShell { }) preferLocalBuild phases buildPhase;
        nativeBuildInputs = config.packages ++ config.nativeBuildInputs;
        env = config.finalEnv;
      } config.additionalArguments
    );
  };
}
