{
  config,
  lib,
  systemConfig,
  ...
}:

let

  inherit (lib) mkEnableOption mkIf;

  cfg = config.pre-commit;

in

{
  options.pre-commit = {
    enable = mkEnableOption "`pre-commit` integration";
  };

  config = mkIf cfg.enable {

    shellHook = systemConfig.pre-commit.installationScript;

    nativeBuildInputs = systemConfig.pre-commit.settings.enabledPackages ++ [
      systemConfig.pre-commit.settings.package
    ];

  };
}
