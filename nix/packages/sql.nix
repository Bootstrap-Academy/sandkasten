{ lib, pkgs, ... }:

{
  name = "SQL";
  version = pkgs.sqlite.version;
  meta = {
    inherit (pkgs.sqlite.meta) description homepage;
    dialect = "sqlite";
  };
  default_main_file_name = "code.sql";

  run.path = lib.attrValues { inherit (pkgs) sqlite; };
  run.environment.HOME = "/tmp";
  run.script = ''
    cd /program
    sqlite3 -json :memory: < $1
  '';

  test.main_file.content = # sql
    ''
      SELECT 'OK' as out;
    '';
  test.files = [ ];
  test.expected = builtins.toJSON [ { out = "OK"; } ];
}
