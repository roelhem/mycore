toplevel@{
  lib,
  inputs,
}:

let

  nix-files = import ./nix-files.nix { inherit lib; };

  inherit (nix-files) zipDirsNixFiles;

in

nix-files
// {
  inherit nix-files;

  /**
    Creates a new flake with my default configuration.

    This is like flake-parts mkFlake, but also auto-imports the modules under nix/modules/flake.

    # Arguments

    inputs
    : The inputs of the flake itself.

    root
    : The root of the flake. Useful to prevent infinite recursion.

    specialArgs
    : Extra arguments to pass to the flake that can be used for imports.

    autowireFlakeModules
    : Whether to autowire the flake modules.

    flakeModulePaths
    : A list of paths from which flake modules are autowired.
  */
  mkFlake =
    {
      inputs,
      root,
      # The systems that are supported by this flake.
      specialArgs ? { },
      # Whether to autowire flake modules.
      autowireFlakeModules ? true,
      # The paths flake-part modules that you want to auto-wire.
      flakeModulePaths ? [
        "nix/modules/flake"
        "nix/modules/flake-parts"
      ],
    }:
    let

      mycoreInputs = toplevel.inputs;

      nixpkgs-stable = inputs.nixpkgs-stable or mycoreInputs.nixpkgs-stable;
      flake-parts = inputs.flake-parts or mycoreInputs.flake-parts;
      treefmt-nix = inputs.treefmt-nix or mycoreInputs.treefmt-nix;
      git-hooks-nix = inputs.git-hooks-nix or mycoreInputs.git-hooks-nix;

    in
    module:
    flake-parts.lib.mkFlake
      {
        inherit inputs;
        specialArgs = {
          inherit mycoreInputs;
        } // specialArgs;
      }
      {

        imports =
          let

            moduleDirs = map (
              p: if builtins.isPath p then p else (if lib.hasPrefix "/" p then p else "${root}/${p}")
            ) flakeModulePaths;

            autowireModules = lib.flatten (builtins.attrValues (zipDirsNixFiles moduleDirs));

          in
          [
            flake-parts.flakeModules.flakeModules
            treefmt-nix.flakeModule
            git-hooks-nix.flakeModule
            ../modules/flake/lib.nix
            ../modules/flake/autowire.nix
            ../modules/flake/defaults.nix
            ../modules/flake/docs
            ../modules/flake/devShells
            ../modules/flake/languages
          ]
          ++ (if autowireFlakeModules then autowireModules else [ ])
          ++ [
            module
          ];

        _module.args = { inherit root; };

        perSystem =
          { system, ... }:
          {
            _module.args = {
              stable = import nixpkgs-stable {
                inherit system;
              };
            };
          };
      };
}
