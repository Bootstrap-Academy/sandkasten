{
  crane,
  lib,
  pkgs,
}:

let
  craneLib = crane.mkLib pkgs;

  commonArgs = {
    src = lib.fileset.toSource {
      root = ../.;
      fileset = lib.fileset.unions [
        ../.cargo
        ../Cargo.lock
        ../Cargo.toml
        ../client
        ../nix/tests
        ../src
      ];
    };

    cargoExtraArgs = "--workspace";

    cargoArtifacts = craneLib.buildDepsOnly commonArgs;
  };
in

{
  sandkasten = craneLib.buildPackage (
    commonArgs
    // {
      pname = "sandkasten";
      cargoExtraArgs = "-p sandkasten";
    }
  );

  sandkasten-tests = craneLib.buildPackage (
    commonArgs
    // {
      pname = "sandkasten-tests";
      cargoExtraArgs = "-p sandkasten-tests";
    }
  );

  clippy = craneLib.cargoClippy (
    commonArgs // { cargoClippyExtraArgs = "--all-targets -- --deny warnings"; }
  );
}
