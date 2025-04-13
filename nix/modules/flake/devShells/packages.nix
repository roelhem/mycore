{
  lib,
  config,
  ...
}:
let
  mkPackagesOption =
    description:
    lib.mkOption {
      inherit description;
      default = [ ];
      type = lib.types.listOf lib.types.package;
    };
in
{
  options = {
    inputsFrom = mkPackagesOption "Packages whose inputs are available in the shell environment.";
    packages = mkPackagesOption "Packages available in the shell environment. An alias of `nativeBuildInputs`";
    nativeBuildInputs = mkPackagesOption "Packages available in the shell environment.";
    buildInputs = lib.mkOption {
      visible = false;
      default = [ ];
      type = lib.types.listOf lib.types.package;
    };
    propagatedBuildInputs = lib.mkOption {
      visible = false;
      default = [ ];
      type = lib.types.listOf lib.types.package;
    };
    propagatedNativeBuildInputs = lib.mkOption {
      visible = false;
      default = [ ];
      type = lib.types.listOf lib.types.package;
    };
  };
  config =
    let
      collectInputs =
        name: (lib.subtractLists config.inputsFrom (lib.flatten (lib.catAttrs name config.inputsFrom)));
    in
    (lib.genAttrs [
      "buildInputs"
      "nativeBuildInputs"
      "propagatedBuildInputs"
      "propagatedNativeBuildInputs"
    ] collectInputs)
    // {
      shellHook = lib.mkBefore (lib.concatLines (lib.catAttrs "shellHook" config.inputsFrom));
    };
}
