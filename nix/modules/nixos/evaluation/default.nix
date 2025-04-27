{ config, lib, ... }:

with lib;

let

  cfg = config.mycore.evaluation;

in

{

  options.mycore.evaluation = {
    enable = mkEnableOption "Evaluation of the configuration by virtualization.";

    graphical = mkOption {
      type = types.bool;
      default = true;
      description = "Whether this machine should be used with a graphical interface.";
    };
  };

  config = mkIf cfg.enable {

    virtualisation.vmVariant = {
      networking.useDHCP = mkDefault false;
      networking.interfaces.eth0.useDHCP = mkDefault true;

      # services.getty.autologinUser = defaultUser.name;
      security.sudo.wheelNeedsPassword = false;

      virtualisation.graphics = mkDefault cfg.graphical;
    };

  };
}
