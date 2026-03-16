{ pkgs, radicle-update }:

radicle-update.lib.mkUpdater {
  inherit pkgs;
  updaters = [
    "cargo"
    "nix-flake"
  ];
}
