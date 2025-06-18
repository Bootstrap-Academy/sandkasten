{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-master.url = "github:NixOS/nixpkgs";
    nixpkgs-csharp.url = "github:NixOS/nixpkgs/0c582677378f2d9ffcb01490af2f2c678dcb29d3";
    fenix.url = "github:nix-community/fenix";
  };

  outputs =
    {
      self,
      nixpkgs,
      fenix,
      ...
    }@inputs:
    let
      defaultSystems = [
        "x86_64-linux"
        "aarch64-linux" # untested
      ];
      eachDefaultSystem =
        f:
        builtins.listToAttrs (
          map (system: {
            name = system;
            value = f (import nixpkgs { inherit system; });
          }) defaultSystems
        );

      lib = import ./nix/lib.nix;
    in
    {
      packages = eachDefaultSystem (pkgs: {
        default = self.packages.${pkgs.system}.sandkasten;
        inherit (self.packages.${pkgs.system}.rustPackages) sandkasten;
        rustPackages = pkgs.callPackages ./nix/rust_packages.nix { inherit fenix; };
        packages = import ./nix/packages {
          inherit inputs lib;
          inherit (pkgs) system;
        };
        time = pkgs.callPackage ./nix/time { };

        tests = pkgs.callPackage ./nix/tests { inherit self; };

        generate = pkgs.writeShellScriptBin "generate" ''
          ${nixpkgs.lib.getExe inputs.nixpkgs-master.legacyPackages.${pkgs.system}.crate2nix} generate
        '';

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
      });

      nixosModules.sandkasten = import ./nix/nixos/module.nix { inherit self lib; };

      devShells = eachDefaultSystem (
        pkgs:
        import ./nix/dev/shell.nix {
          inherit
            self
            pkgs
            lib
            fenix
            ;
        }
      );

      templates.vm.path = ./nix/nixos/vm;

      formatter = eachDefaultSystem (
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
