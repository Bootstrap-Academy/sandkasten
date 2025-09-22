{ lib, pkgs, ... }:

{
  name = "C++";
  version = "20";
  meta = {
    compiler = {
      name = "GCC";
      version = pkgs.gcc.version;
      inherit (pkgs.gcc.meta) description longDescription homepage;
    };
  };
  default_main_file_name = "code.cpp";

  compile.path = lib.attrValues { inherit (pkgs) gcc; };
  compile.script = ''
    g++ -std=c++20 -O2 -o /program/binary "$1"
  '';

  run.script = ''
    shift
    /program/binary "$@"
  '';

  example = # cpp
    ''
      #include <bits/stdc++.h>

      int main() {
        std::string name;
        std::cin >> name;
        std::cout << "Hello, " << name << "!";
        return 0;
      }
    '';

  test.main_file.content = # cpp
    ''
      #include "foo.cpp"

      int main(int argc, char** argv) {
        std::string s;
        std::cin >> s;
        if (s != "stdin") return 1;

        if (argc-1 != 3) return 2;
        if (strcmp(argv[1], "foo")) return 3;
        if (strcmp(argv[2], "bar")) return 4;
        if (strcmp(argv[3], "baz")) return 5;

        std::ifstream file;
        file.open("test.txt");
        getline(file, s);
        if (s != "hello world") return 6;

        bar();
        return 0;
      }
    '';
  test.files = [
    {
      name = "foo.cpp";
      content = # cpp
        ''
          #include <bits/stdc++.h>
          void bar() {
            std::cout << "OK";
          }
        '';
    }
  ];
}
