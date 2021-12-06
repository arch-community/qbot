{ lib, pkgs, config, ... }:

with lib;
let
  format = pkgs.formats.json { };
  cfg = config.services.qbot;
  configFile = pkgs.writeText "config.json" (builtins.toJSON cfg.config);
in {
  options.services.qbot = {
    enable = mkEnableOption "qbot service";
    config = mkOption {
      default = {};
      description = "Configuration for qbot";
      type = format.type;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.qbot = {
      description = "qbot discord bot";

      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.qbot}/bin/qbot -c ${configFile} --state-dir \${STATE_DIRECTORY} --no-console";
        StateDirectory = "qbot";
        DynamicUser = true;
      };
    };
  };
}
