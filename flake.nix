{
  description = "Core Configuration for my personal projects";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      ...
    }:
    let
      m = flake-parts.lib.evalFlakeModule { inherit inputs; } (
        {
          config,
          moduleType,
          withSystem,
          ...
        }:
        let

          # The default nixpkgs library.
          lib = nixpkgs.lib;

          # The default systems.
          defaultSystems = [
            "x86_64-linux"
            "aarch64-linux"
            "i686-linux"
            "x86_64-darwin"
            "aarch64-darwin"
          ];

        in
        {

          # Import flake modules here.
          imports = [
            inputs.devshell.flakeModule
            flake-parts.flakeModules.flakeModules
            ./nix/modules/flake/devshells.nix
            ./nix/modules/flake/lib.nix
            ./nix/modules/flake/autowire.nix
            ./nix/modules/flake/docs
          ];

          # The systems supported by this project.
          systems = defaultSystems;

          mycore.autowire.enable = true;

          # Per-system attributes.
          perSystem =
            {
              config,
              self',
              inputs',
              pkgs,
              system,
              ...
            }:
            {
              # apps = { };

              # packages = { };

              # checks = { };

              # devShells = { };

              # The nix formatter used in this project. This is the package
              # that is used when running `nix fmt`.
              formatter = pkgs.nixfmt-rfc-style;

              docs.default = {
                enable = true;
                sections.flake.nixModuleOptions.options = moduleType.getSubOptions [ ];
                sections.flake.nixModuleOptions.enable = true;
              };
            };

          # The usual flake attributes, including system-agnostic ones.
          flake = {

            inherit moduleType;

            lib = import ./nix/lib { inherit lib defaultSystems inputs; };

            docs = withSystem "aarch64-darwin" (
              { pkgs, ... }: pkgs.nixosOptionsDoc { options = moduleType.getSubOptions [ ]; }
            );
            # lib = ...;

            # overlays = { };

            # templates = { };

            # nixosConfigurations = { };

            # nixosModules = { };

            # darwinConfigurations = { };

            # darwinModules = { };
          };
        }
      );
    in
    m.config.flake;
}
