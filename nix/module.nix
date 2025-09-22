{ self }:

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.sandkasten;
  settingsFormat = pkgs.formats.toml { };

  environments = cfg.environments self.packages.${pkgs.system}.sandkastenPackages;

  limitsModule = type: {
    options = {
      cpus = lib.mkOption {
        type = lib.types.ints.positive;
        description = "The maximum number of cpus the process is allowed to use.";
        default = 1;
      };

      time = lib.mkOption {
        type = lib.types.ints.positive;
        description = "The number of **seconds** the process is allowed to run.";
        default =
          {
            compile = 30;
            run = 5;
          }
          .${type};
      };

      memory = lib.mkOption {
        type = lib.types.ints.positive;
        description = "The amount of memory the process is allowed to use (in **MB**).";
        default =
          {
            compile = 1024;
            run = 256;
          }
          .${type};
      };

      tmpfs = lib.mkOption {
        type = lib.types.ints.unsigned;
        description = "The size of the tmpfs mounted at /tmp (in **MB**).";
        default = 256;
      };

      filesize = lib.mkOption {
        type = lib.types.ints.positive;
        description = "The maximum size of a file the process is allowed to create (in **MB**).";
        default = 16;
      };

      file_descriptors = lib.mkOption {
        type = lib.types.ints.positive;
        description = "The maximum number of file descripters the process can open at the same time.";
        default = 256;
      };

      processes = lib.mkOption {
        type = lib.types.ints.positive;
        description = "The maximum number of processes that can run concurrently in the sandbox.";
        default =
          {
            compile = 256;
            run = 64;
          }
          .${type};
      };

      stdout_max_size = lib.mkOption {
        type = lib.types.ints.unsigned;
        description = "The maximum number of bytes that are read from stdout.";
        default = 65536;
      };

      stderr_max_size = lib.mkOption {
        type = lib.types.ints.unsigned;
        description = "The maximum number of bytes that are read from stderr.";
        default = 65536;
      };

      network = lib.mkOption {
        type = lib.types.bool;
        description = "Whether the process is allowed to access the network.";
        default = false;
      };
    };
  };
in

{
  meta.maintainers = with lib.maintainers; [ defelo ];
  _file = ./module.nix;

  options.services.sandkasten = {
    enable = lib.mkEnableOption "sandkasten";

    package = lib.mkPackageOption self.packages.${pkgs.system} "sandkasten" {
      pkgsText = "sandkasten.packages.\${system}";
    };

    nsjailPackage = lib.mkPackageOption pkgs "nsjail" { };

    timePackage = lib.mkPackageOption self.packages.${pkgs.system} "time" {
      pkgsText = "sandkasten.packages.\${system}";
    };

    environments = lib.mkOption {
      type = lib.types.functionTo lib.types.package;
      description = "Sandkasten packages to install.";
      defaultText = lib.literalExpression ''
        sandkastenPackages: sandkastenPackages.all
      '';
      example = lib.literalExpression ''
        sandkastenPackages: sandkastenPackages.select (p: with p; [
          python
          rust
        ])
      '';
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
        options = {
          host = lib.mkOption {
            type = lib.types.str;
            description = "The host to listen on.";
            default = "127.0.0.1";
          };

          port = lib.mkOption {
            type = lib.types.port;
            description = "The port to listen on.";
            default = 8000;
          };

          server = lib.mkOption {
            type = lib.types.str;
            description = ''
              The path prefix added by a reverse proxy.
              Set to `"/"` if you don't have a reverse proxy.
            '';
            default = "/";
          };

          enable_metrics = lib.mkOption {
            type = lib.types.bool;
            description = "Whether to expose Prometheus metrics on `/metrics`.";
            default = false;
          };

          programs_dir = lib.mkOption {
            type = lib.types.path;
            description = "The directory where programs are stored.";
            default = "/var/lib/sandkasten/programs";
          };

          jobs_dir = lib.mkOption {
            type = lib.types.path;
            description = "The directory where files for jobs are stored.";
            default = "/run/sandkasten/jobs";
          };

          program_ttl = lib.mkOption {
            type = lib.types.ints.unsigned;
            description = "The time to live for programs in seconds.";
            default = 600;
          };

          prune_programs_interval = lib.mkOption {
            type = lib.types.ints.unsigned;
            description = "The number of seconds to wait between deleting old programs.";
            default = 60;
          };

          max_concurrent_jobs = lib.mkOption {
            type = lib.types.ints.unsigned;
            description = "The maximum number of jobs that can run at the same time.";
            default = 4;
          };

          compile_limits = lib.mkOption {
            type = lib.types.submodule (limitsModule "compile");
            description = "The maximum allowed limits for compile steps.";
            default = { };
          };

          run_limits = lib.mkOption {
            type = lib.types.submodule (limitsModule "run");
            description = "The maximum allowed limits for run steps.";
            default = { };
          };

          base_resource_usage = lib.mkOption {
            type = lib.types.submodule {
              options = {
                runs = lib.mkOption {
                  type = lib.types.ints.positive;
                  description = "The number of times the program is run.";
                  default = 20;
                };

                permits = lib.mkOption {
                  type = lib.types.ints.positive;
                  description = ''
                    The number of permits to acquire from the internal request semaphore.
                    If set to the value of [](#opt-services.sandkasten.settings.max_concurrent_jobs)
                    or more (the default), no other jobs can run at the same time.
                  '';
                  defaultText = lib.literalExpression "config.services.sandkasten.settings.max_concurrent_jobs";
                };

                cache_ttl = lib.mkOption {
                  type = lib.types.ints.unsigned;
                  description = "The time to live for base resource usage cache entries in seconds.";
                  default = 3600;
                };
              };
            };
            description = "Config for measuring the base resource usage of an environment.";
          };
        };
      };
      description = "Sandkasten configuration.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.sandkasten = {
      environments = lib.mkDefault (sandkastenPackages: sandkastenPackages.all);

      settings = {
        base_resource_usage.permits = lib.mkDefault cfg.settings.max_concurrent_jobs;
        nsjail_path = lib.getExe cfg.nsjailPackage;
        time_path = lib.getExe cfg.timePackage;
        environments_path = [ environments ];
      };
    };

    systemd.services.sandkasten = {
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = lib.getExe cfg.package;

        StateDirectory = "sandkasten";
        RuntimeDirectory = "sandkasten";

        Restart = lib.mkDefault "always";
        RestartSec = lib.mkDefault 1;
        OOMPolicy = lib.mkDefault "continue";

        # hardening
        # AmbientCapabilities = [ "" ];
        # CapabilityBoundingSet = [ "" ];
        # DevicePolicy = "closed";
        # LockPersonality = true;
        # MemoryDenyWriteExecute = true;
        # NoNewPrivileges = true;
        # PrivateDevices = true;
        # PrivateTmp = true;
        # PrivateUsers = true;
        # ProcSubset = "pid";
        # ProtectClock = true;
        # ProtectControlGroups = true;
        # ProtectHome = true;
        # ProtectHostname = true;
        # ProtectKernelLogs = true;
        # ProtectKernelModules = true;
        # ProtectKernelTunables = true;
        # ProtectProc = "invisible";
        # ProtectSystem = "strict";
        # RemoveIPC = true;
        # RestrictAddressFamilies = [ "AF_INET AF_INET6 AF_UNIX" ];
        # RestrictNamespaces = true;
        # RestrictRealtime = true;
        # RestrictSUIDSGID = true;
        # SocketBindAllow = lib.mkIf (cfg.listenAddress ? tcp) "tcp:${toString cfg.listenAddress.tcp.port}";
        # SocketBindDeny = "any";
        # SystemCallArchitectures = "native";
        # SystemCallFilter = [
        #   "@system-service"
        #   "~@privileged"
        #   "~@resources"
        # ];
        # UMask = "0077";
      };

      environment.CONFIG_PATH = settingsFormat.generate "sandkasten-config.toml" cfg.settings;
    };
  };
}
