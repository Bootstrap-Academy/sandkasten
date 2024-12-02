{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-master.url = "github:NixOS/nixpkgs";
    nixpkgs-csharp.url = "github:NixOS/nixpkgs/0c582677378f2d9ffcb01490af2f2c678dcb29d3";
    fenix.url = "github:nix-community/fenix";
  };

  outputs = {
    self,
    nixpkgs,
    fenix,
    ...
  } @ inputs: let
    defaultSystems = [
      "x86_64-linux"
      "aarch64-linux" # untested
    ];
    eachDefaultSystem = f:
      builtins.listToAttrs (map (system: {
          name = system;
          value = f (import nixpkgs {inherit system;});
        })
        defaultSystems);
    lib = import ./nix/lib.nix;
  in {
    packages = eachDefaultSystem (pkgs: {
      default = self.packages.${pkgs.system}.sandkasten;
      sandkasten = pkgs.callPackage ./nix/sandkasten.nix {inherit fenix;};
      packages = import ./nix/packages {
        inherit inputs lib;
        inherit (pkgs) system;
      };
      time = pkgs.callPackage ./nix/time {};

      generate = pkgs.writeShellScriptBin "generate" ''
        ${nixpkgs.lib.getExe pkgs.crate2nix} generate
      '';
    });
    nixosModules.sandkasten = import ./nix/nixos/module.nix {
      inherit self lib;
    };
    devShells = eachDefaultSystem (pkgs: import ./nix/dev/shell.nix {inherit self pkgs lib;});
    templates.vm.path = ./nix/nixos/vm;

    checks = builtins.mapAttrs (_: packages: packages // {packages = packages.packages.all;}) self.packages;
  };
}
