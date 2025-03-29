toplevel@{
  lib,
  defaultSystems,
  inputs,
}:

{
  mkFlake =
    {
      inputs,
      root,
      # The systems that are supported by this flake.
      systems ? defaultSystems,
      specialArgs ? { },
    }:
    let

      flake-parts = inputs.flake-parts or toplevel.inputs.flake-parts;

    in

    flake-parts.lib.mkFlake
      {
        inherit inputs;
        specialArgs = {
          mycoreInputs = toplevel.inputs;
        } // specialArgs;
      }
      {

        _module.args = { inherit root; };

        inherit systems;

        imports = [ ];

      };
}
