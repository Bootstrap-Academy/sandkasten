{ lib, pkgs, ... }:

let
  cargoToml = lib.importTOML ./Cargo.toml;
  rustEdition = cargoToml.package.edition;
in

{
  tree-root-file = ".git/config";
  on-unmatched = "fatal";

  excludes = [
    "*.lock"
    "*.md"
    "*.patch"
    ".envrc"
    ".gitattributes"
    ".gitignore"
    "Cargo.nix"
    "LICENSE"
    "tests/proptests.proptest-regressions"
  ];

  formatter.nixfmt = {
    command = lib.getExe pkgs.nixfmt-rfc-style;
    includes = [ "*.nix" ];
    options = [ "--strict" ];
  };

  formatter.prettier = {
    command = lib.getExe pkgs.nodePackages.prettier;
    includes = [
      "*.json"
      "*.yml"
    ];
    options = [ "--write" ];
  };

  formatter.rustfmt = {
    command = lib.getExe pkgs.rustfmt;
    includes = [ "*.rs" ];
    options = [
      "--config=skip_children=true"
      "--edition=${rustEdition}"
    ];
  };

  formatter.shfmt = {
    command = lib.getExe pkgs.shfmt;
    includes = [ "*.sh" ];
    options = [
      "--simplify"
      "--write"
      "--indent=2"
    ];
  };

  formatter.taplo = {
    command = lib.getExe pkgs.taplo;
    includes = [ "*.toml" ];
    options = [
      "format"
      "--option=column_width=120"
      "--option=align_comments=false"
    ];
  };
}
