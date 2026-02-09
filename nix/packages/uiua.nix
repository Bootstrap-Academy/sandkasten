{ lib, pkgs-unstable, ... }:

let
  inherit (pkgs-unstable) uiua;
in

{
  name = "Uiua";
  version = uiua.version;
  meta = { inherit (uiua.meta) description longDescription homepage; };
  default_main_file_name = "code.ua";

  run.path = lib.attrValues { inherit uiua; };
  run.extra_tmpfs = [ "/box/uiua-modules" ];
  run.script = ''
    uiua run --no-format /program/"$@"
  '';

  example = # uiua
    ''
      &p $"Hello, _!" &fras "/dev/stdin"
    '';

  test.main_file.content = # uiua
    ''
      ~ "foo.ua" ~ Bar
      ⍤"stdin" ≍"stdin" &fras "/dev/stdin"
      ⍤"args" ≍{"foo" "bar" "baz"} ↘1 &args
      ⍤"file" ≍"hello world" &fras "test.txt"
      &p Bar @K
    '';
  test.files = [
    {
      name = "foo.ua";
      content = # uiua
        ''
          Bar ← ⊂@O
        '';
    }
  ];
}
