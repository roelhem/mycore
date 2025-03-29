{
  # A short description of this project.
  description = "Some personal project";

  # The dependencies of this project.
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    mycore.url = "github:roelhem/mycore";
    mycore.inputs.nixpkgs.follows = "nixpkgs";
  };

  # The outputs of this project.
  outputs =
    inputs@{ mycore, ... }:
    mycore.lib.mkFlake
      {
        inherit inputs;
        root = ./.;
      }
      (
        { ... }:
        {
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
            { };

          # The usual flake attributes, including system-agnostic ones.
          flake = { };
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
