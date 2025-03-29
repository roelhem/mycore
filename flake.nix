{
  description = "Core Configuration for my personal projects";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      flake-parts,
      treefmt-nix,
      nixpkgs,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        config,
        moduleType,
        withSystem,
        ...
      }:
      let

        # The default nixpkgs library.
        lib = nixpkgs.lib;

      in
      {

        # Import flake modules here.
        imports = [
          inputs.devshell.flakeModule
          flake-parts.flakeModules.flakeModules
          treefmt-nix.flakeModule
          ./nix/modules/flake/devshells.nix
          ./nix/modules/flake/lib.nix
          ./nix/modules/flake/autowire.nix
          ./nix/modules/flake/defaults.nix
          ./nix/modules/flake/docs
        ];

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
            # formatter = pkgs.nixfmt-rfc-style;
          };

        # The usual flake attributes, including system-agnostic ones.
        flake = {

          lib = import ./nix/lib { inherit lib inputs; };

          templates = {
            default = {
              path = ./nix/templates/default;
              description = "Simple way to setup a personal project.";
            };
          };

          # overlays = { };

          # templates = { };

          # nixosConfigurations = { };

          # nixosModules = { };

          # darwinConfigurations = { };

          # darwinModules = { };
        };
      }
    );

  # Extra recommended nix configuration.
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://roelhem.cachix.org"
    ];

    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "roelhem.cachix.org-1:6UktCbfTJhgub82/RuVYKw6645qrrEwDGJMjhBQYYCA="
    ];
  };
}
