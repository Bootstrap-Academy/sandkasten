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
        ../config.toml
        ../nix/tests/Cargo.toml
        ../nix/tests/src
        ../src
      ];
    };

    cargoExtraArgs = "--workspace";

    cargoArtifacts = craneLib.buildDepsOnly commonArgs;
  };

  commonArgsNightly = commonArgs // {
    env.RUSTC_BOOTSTRAP = 1;
    cargoArtifacts = craneLib.buildDepsOnly commonArgsNightly;
  };
in

{
  sandkasten = craneLib.buildPackage (
    commonArgs
    // {
      pname = "sandkasten";
      cargoExtraArgs = "-p sandkasten";

      passthru = {
        clippy = craneLib.cargoClippy (
          commonArgs
          // {
            pname = "sandkasten-clippy";
            cargoClippyExtraArgs = "--all-targets -- --deny warnings";
          }
        );

        doc = craneLib.cargoDoc (
          commonArgsNightly
          // {
            pname = "sandkasten-doc";
            env = commonArgsNightly.env // {
              RUSTDOCFLAGS = "--deny warnings --cfg docsrs";
            };
          }
        );

        test = craneLib.cargoTest (commonArgsNightly // { pname = "sandkasten-test"; });

        hack = craneLib.mkCargoDerivation (
          commonArgs
          // {
            pname = "sandkasten-hack";
            nativeBuildInputs = [ pkgs.cargo-hack ];
            buildPhaseCargoCommand = ''
              cargo hack --workspace --feature-powerset check
            '';
          }
        );
      };

      meta = {
        description = "Run untrusted code in an isolated environment";
        homepage = "https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K";
        license = lib.licenses.mit;
        mainProgram = "sandkasten";
        maintainers = with lib.maintainers; [ defelo ];
      };
    }
  );

  sandkasten-tests = craneLib.buildPackage (
    commonArgs
    // {
      pname = "sandkasten-tests";
      cargoExtraArgs = "-p sandkasten-tests";
      meta.mainProgram = "sandkasten-tests";
    }
  );
}
