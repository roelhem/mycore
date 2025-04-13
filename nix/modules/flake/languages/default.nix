{
  lib,
  flake-parts-lib,
  ...
}:

let

  inherit (flake-parts-lib) mkPerSystemOption;

in

{
  options.perSystem = mkPerSystemOption (
    {
      pkgs,
      stable,
      config,
      ...
    }:
    {
      imports = [
        ./haskell.nix
        ./elm.nix
        ./just.nix
        ./go.nix
        ./javascript.nix
        ./python.nix
      ];
    }
  );
}
