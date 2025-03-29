{
  config,
  ...
}:

{
  config = {
    perSystem =
      { pkgs, ... }:
      {
        devshells.default = {
          packages = [ pkgs.nixdoc ];
        };
      };
  };
}
