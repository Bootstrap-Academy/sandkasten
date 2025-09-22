{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs";
    nixpkgs-csharp.url = "github:NixOS/nixpkgs/0c582677378f2d9ffcb01490af2f2c678dcb29d3";
    crane.url = "github:ipetkov/crane";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:

    let
      eachSystem = f: nixpkgs.lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s});
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      lib = import ./nix/lib.nix;
    in

    {
      packages = eachSystem (
        pkgs:
        let
          pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system};
        in
        {
          default = self.packages.${pkgs.system}.sandkasten;
          inherit (self.packages.${pkgs.system}.rustPackages) sandkasten;
          rustPackages = pkgs-unstable.callPackages ./nix/rust_packages.nix { inherit (inputs) crane; };
          packages = import ./nix/packages {
            inherit inputs lib;
            inherit (pkgs) system;
          };
          time = pkgs.callPackage ./nix/time { };

          tests = pkgs.callPackage ./nix/tests { inherit self; };

          checks =
            let
              packages = pkgs.linkFarm "sandkasten-checks-packages" (
                builtins.removeAttrs self.packages.${pkgs.system} [ "checks" ]
                // {
                  packages = self.packages.${pkgs.system}.packages.all;
                  rustPackages =
                    pkgs.linkFarm "sandkasten-checks-rustPackages"
                      self.packages.${pkgs.system}.rustPackages;
                }
              );
              devShells = pkgs.linkFarm "sandkasten-checks-devShells" self.devShells.${pkgs.system};
            in
            pkgs.linkFarmFromDrvs "sandkasten-checks" [
              packages
              devShells
            ];
        }
      );

      nixosModules.sandkasten = import ./nix/nixos/module.nix { inherit self lib; };

      devShells = eachSystem (pkgs: import ./nix/dev/shell.nix { inherit self pkgs lib; });

      templates.vm.path = ./nix/nixos/vm;

      formatter = eachSystem (
        { system, ... }:
        let
          pkgs = inputs.nixpkgs-master.legacyPackages.${system};
        in
        pkgs.treefmt.withConfig {
          settings = [
            ./treefmt.nix
            { _module.args = { inherit pkgs; }; }
          ];
        }
      );
    };

  nixConfig = {
    extra-substituters = "https://attic.defelo.de/sandkasten";
    extra-trusted-public-keys = "sandkasten:U7kShJt9A6tZr4pZRAXHmRlxC3nmOGvfviPqKL7hROE=";
  };
}
