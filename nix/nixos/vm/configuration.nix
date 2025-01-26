{pkgs, ...}: {
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.timeout = 2;

  boot.tmp.useTmpfs = true;

  console.keyMap = "us";

  time.timeZone = "UTC";

  networking.hostName = "sandkasten";
  networking.firewall.allowedTCPPorts = [80];

  users.users.root.initialPassword = "sandkasten";

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  services.getty.autologinUser = "root";

  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 3d";
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes" "repl-flake"];
      substituters = [
        "https://attic.defelo.de/sandkasten"
      ];
      trusted-public-keys = [
        "sandkasten:U7kShJt9A6tZr4pZRAXHmRlxC3nmOGvfviPqKL7hROE="
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    neovim
    wget
    htop
    duf
    ncdu
    dig
    git
  ];
  environment.shellAliases.vim = "nvim";

  system.stateVersion = "23.05";
}
