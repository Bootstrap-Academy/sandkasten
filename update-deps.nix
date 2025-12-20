{
  pkgs,
  radicle-update,
  writers,
}:

writers.writeNuBin "update-deps" # nu
  ''
    source ${radicle-update.lib.rad-update}
    source ${radicle-update.lib.updaters.cargo pkgs}
    source ${radicle-update.lib.updaters.nix-flake}

    rad update {
      rad update cargo
      rad update nix-flake
    }
  ''
