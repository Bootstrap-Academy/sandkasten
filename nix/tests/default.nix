{
  lib,
  self,
  stdenv,
  testers,
}:

let
  disabledTests = [
    "attacks::.*"
    "proptests::.*"
  ];
in

testers.runNixOSTest {
  name = "sandkasten";

  nodes.machine =
    { config, pkgs, ... }:
    {
      imports = [ self.nixosModules.default ];

      services.sandkasten = {
        enable = true;
        environments = sandkastenPackages: sandkastenPackages.all;
        settings = {
          host = "0.0.0.0";
          port = 8000;

          program_ttl = 60;
          prune_programs_interval = 30;

          max_concurrent_jobs = 2;

          compile_limits.time = 300;
          run_limits.time = 300;
          run_limits.network = true;
        };
      };

      services.nginx = {
        enable = true;
        virtualHosts."localhost".locations."/".return = "200 \"Hello World!\"";
      };

      environment.systemPackages = [ self.packages.${stdenv.hostPlatform.system}.sandkasten-tests ];

      virtualisation.memorySize = 4096;
      virtualisation.cores = 4;
    };

  interactive.nodes.machine =
    { pkgs, ... }:
    {
      virtualisation.graphics = false;
      services.openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "yes";
          PermitEmptyPasswords = "yes";
        };
      };
      security.pam.services.sshd.allowNullPassword = true;

      networking.firewall.enable = false;
      virtualisation.forwardPorts = [
        {
          from = "host";
          host.port = 2222;
          guest.port = 22;
        }
        {
          from = "host";
          host.port = 8000;
          guest.port = 8000;
        }
      ];

      environment.systemPackages = with pkgs; [ htop ];
    };

  testScript = ''
    machine.start()

    machine.wait_for_unit("sandkasten.service")
    machine.wait_for_open_port(8000)

    machine.wait_for_unit("nginx.service")
    machine.wait_for_open_port(80)

    machine.succeed("sandkasten-tests '!^${lib.concatStringsSep "$|^" disabledTests}$'")
  '';
}
