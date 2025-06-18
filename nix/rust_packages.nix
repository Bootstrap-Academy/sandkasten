{
  fenix,
  lib,
  pkgs,
  system,
}:

let
  toolchain = fenix.packages.${system}.stable;

  crateOverrides = {
    sandkasten = _: {
      src = lib.fileset.toSource {
        root = ../.;
        fileset = ../src;
      };
    };
    sandkasten-client = _: {
      src = lib.fileset.toSource {
        root = ../client;
        fileset = lib.fileset.unions [
          ../client/src
          ../client/README.md
        ];
      };
    };
    sandkasten-tests = _: {
      src = lib.fileset.toSource {
        root = ./tests;
        fileset = ./tests/src;
      };
    };
  };

  cargoNix = pkgs.callPackage ../Cargo.nix {
    pkgs = pkgs.extend (
      final: prev: {
        inherit (toolchain) cargo;
        # workaround for https://github.com/NixOS/nixpkgs/blob/d80a3129b239f8ffb9015473c59b09ac585b378b/pkgs/build-support/rust/build-rust-crate/default.nix#L19-L23
        rustc = toolchain.rustc // {
          unwrapped.configureFlags = [ "--target=" ];
        };
      }
    );
    defaultCrateOverrides = pkgs.defaultCrateOverrides // crateOverrides;
  };
in

lib.mapAttrs (_: p: p.build) cargoNix.workspaceMembers
