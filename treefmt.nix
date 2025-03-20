{
  settings.global.excludes = [
    "*.md"
    ".envrc"
    ".gitattributes"
    "Cargo.nix"
    "LICENSE"
    "tests/proptests.proptest-regressions"
  ];

  programs.nixfmt.enable = true;
  programs.nixfmt.strict = true;

  programs.prettier.enable = true;

  programs.rustfmt.enable = true;

  programs.shfmt.enable = true;

  programs.taplo.enable = true;
  settings.formatter.taplo.options = [
    "--option=column_width=120"
    "--option=align_comments=false"
  ];
}
