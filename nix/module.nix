{ nixConfig, ... }:

{ lib, pkgs, config, ... }:

let
    cfg = config.services.qbot;

    configFile = pkgs.writeText "config.json" (builtins.toJSON cfg.config);

in {
    options.services.qbot = let
        inherit (lib)
            mkOption mkEnableOption mkPackageOption;
    in {
        enable = mkEnableOption "qbot service";

        package = mkPackageOption pkgs "qbot" { };

        config = let
            inherit (lib.types)
                str int enum nullOr listOf;

            mkOpt' = type: description: default: rest:
                mkOption ({ inherit type description default; } // rest);

            mkOpt = t: d: mkOpt' t d null;

        in {
            token = mkOpt str "Discord gateway bot token" { };
            client_id = mkOpt int "Discord application client ID" { };
            owner = mkOpt int "Discord user ID of the bot's owner" { };

            arch = {
                mirror = mkOpt' str "Mirror server hosting Arch Linux repos"
                    "https://mirrors.edge.kernel.org/archlinux/" { };
                
                repos = mkOpt' (listOf str) "List of repositories to index"
                    [ "core" "extra" "multilib" ] { };
            };

            database = {
                type = mkOpt' (enum [ "sqlite3" "oracle_enhanced" ])
                    "Type of database to connect to" "sqlite3" { };

                db = mkOpt' str "Database name or path" "db.sqlite3" { };

                user = mkOpt (nullOr str) "Database username" { };
                pass = mkOpt (nullOr str) "Database password" { };
            };

            my_repo = mkOpt' str "The bot's VCS repository"
                "https://github.com/arch-community/qbot" { };

            modules = mkOpt (listOf str) "List of modules to load" { };

            default_prefix = mkOpt' str "Default command prefix" "." { };

            bot_id_allowlist = mkOpt (listOf int)
                "User IDs that ignore the bot filter" { };
        };
    };

    config = let
        inherit (lib) mkIf getExe;
    in mkIf cfg.enable {
        systemd.services.qbot = {
            description = "qbot discord bot";

            wantedBy = [ "multi-user.target" ];
            after = [ "network.target" ];

            serviceConfig = {
                ExecStart = "${getExe cfg.package}"
                    + " -c ${configFile}"
                    + " --state-dir \${STATE_DIRECTORY}"
                    + " --no-console";

                StateDirectory = "qbot";
                DynamicUser = true;
            };
        };

        nix.settings = {
            substituters = [ nixConfig.extra-substituters ];
            trusted-public-keys = [ nixConfig.extra-trusted-public-keys ];
        };
    };
}

# vim: et ts=4 sw=4
