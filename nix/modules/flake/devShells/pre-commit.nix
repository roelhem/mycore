{
  config,
  lib,
  systemConfig,
  pkgs,
  ...
}:

let

  inherit (lib) mkEnableOption mkIf;

  cfg = config.pre-commit;

  preCommitInstall = pkgs.writeShellApplication {
    name = "pre-commit-install";

    runtimeInputs = systemConfig.pre-commit.settings.enabledPackages;

    text = systemConfig.pre-commit.installationScript;

    checkPhase = "";
  };

in

{
  options.pre-commit = {
    enable = mkEnableOption "`pre-commit` integration";
  };

  config = mkIf cfg.enable {

    shellHook = "${preCommitInstall}/bin/pre-commit-install";

  };
}
