{ lib, pkgs, ... }:

let
  python = pkgs.python313;
  py-pkgs = p: with p; [ numpy ];
in

{
  name = "Python";
  version = python.version;
  meta = {
    inherit (python.meta) description longDescription homepage;
    packages = map (p: p.pname) (py-pkgs python.pkgs);
  };
  default_main_file_name = "code.py";

  run.path = lib.attrValues { python = python.withPackages py-pkgs; };
  run.script = ''
    python /program/"$@"
  '';

  example = # python
    ''
      name = input()
      print(f"Hello, {name}!")
    '';

  test.main_file.content = # python
    ''
      import sys
      import foo

      if input() != "stdin": exit(1)

      if len(sys.argv)-1 != 3: exit(2)
      if sys.argv[1] != "foo": exit(3)
      if sys.argv[2] != "bar": exit(4)
      if sys.argv[3] != "baz": exit(5)

      if open("test.txt").read() != "hello world": exit(6)

      foo.bar()
    '';
  test.files = [
    {
      name = "foo.py";
      content = # python
        ''
          def bar():
            print("OK")
        '';
    }
  ];
}
