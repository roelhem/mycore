{ flake, ... }:

{
  imports = [ flake.self.nixosModules.evaluation ];

  config = {
    mycore.evaluation.enable = true;
    mycore.evaluation.graphical = false;
  };
}
