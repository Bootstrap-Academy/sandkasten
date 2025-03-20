{
  fenix,
  lib,
  pkgs,
  system,
}:
let
  toolchain = fenix.packages.${system}.stable;

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
  };
in
cargoNix.workspaceMembers.sandkasten.build
