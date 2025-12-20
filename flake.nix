{
  inputs = {
    nixpkgs.follows = "nixpkgs-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-csharp.url = "github:NixOS/nixpkgs/0c582677378f2d9ffcb01490af2f2c678dcb29d3";
    crane.url = "github:ipetkov/crane";
    radicle-update.url = "git+https://radicle.defelo.de/zPrhdopkKmKWdeEJJHx6TvKM832X.git";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:

    let
      inherit (nixpkgs) lib;

      eachSystem = f: lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s});
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      cargoToml = lib.importTOML ./Cargo.toml;
      sandkastenVersion = cargoToml.workspace.package.version;
    in

    {
      packages = eachSystem (
        pkgs:
        pkgs.callPackages ./nix/sandkasten.nix { inherit (inputs) crane; }
        // {
          default = self.packages.${pkgs.system}.sandkasten;

          time = pkgs.callPackage ./nix/time { };

          tests = pkgs.callPackage ./nix/tests { inherit self; };

          docs = pkgs.callPackage ./nix/docs.nix {
            inherit self;
            module = self.nixosModules.default;
          };

          sandkastenPackages = pkgs.callPackage ./nix/packages { inherit inputs sandkastenVersion; };

          sandkastenPackageModuleDocs = pkgs.callPackage ./nix/docs.nix {
            inherit self;
            module = ./nix/packages/module.nix;
          };

          generate = pkgs.writeShellScriptBin "generate" ''
            cat ${self.packages.${pkgs.system}.docs} > nixos-options.md
            cat ${self.packages.${pkgs.system}.sandkastenPackageModuleDocs} > nix/packages/options.md
          '';

          update-deps = pkgs.callPackage ./update-deps.nix { inherit (inputs) radicle-update; };
        }
      );

      nixosModules.default = import ./nix/module.nix { inherit self; };

      devShells = eachSystem (pkgs: {
        default = pkgs.callPackage ./nix/dev.nix { inherit self; };
      });

      formatter = eachSystem (
        pkgs:
        pkgs.treefmt.withConfig {
          settings = lib.mkMerge [
            ./treefmt.nix
            { _module.args = { inherit pkgs; }; }
          ];
        }
      );

      checks = eachSystem (pkgs: {
        inherit (self.packages.${pkgs.system}.default)
          clippy
          doc
          test
          hack
          ;
        packages = pkgs.linkFarm "packages" self.packages.${pkgs.system};
        sandkastenPackages = self.packages.${pkgs.system}.sandkastenPackages.all;
        devShells = pkgs.linkFarm "devShells" self.devShells.${pkgs.system};
        fmt = pkgs.runCommandNoCCLocal "fmt-check" { } ''
          cp -r --no-preserve=mode ${self} repo
          ${lib.getExe self.formatter.${pkgs.system}} -C repo --ci
          touch $out
        '';
        docs = pkgs.runCommandNoCCLocal "docs-check" { } ''
          diff -U3 --color=auto ${./nixos-options.md} ${self.packages.${pkgs.system}.docs}
          diff -U3 --color=auto ${./nix/packages/options.md} ${
            self.packages.${pkgs.system}.sandkastenPackageModuleDocs
          }
          touch $out
        '';
      });
    };

  nixConfig = {
    commit-lock-file-summary = "chore: update flake.lock";
    extra-substituters = "https://attic.defelo.de/sandkasten";
    extra-trusted-public-keys = "sandkasten:U7kShJt9A6tZr4pZRAXHmRlxC3nmOGvfviPqKL7hROE=";
  };
}
