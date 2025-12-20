{
  lib,
  pkgs,
  self,
  ...
}:

let
  inherit (self.packages.${pkgs.stdenv.hostPlatform.system}) time;
  setup-nsjail = pkgs.writeShellScriptBin "setup-nsjail" ''
    if [[ "$UID" != 0 ]]; then
      exec sudo "$0" "$@"
    fi
    cp -a ${pkgs.nsjail}/bin/nsjail .nsjail
    chmod +s .nsjail
  '';
in

pkgs.mkShell {
  packages = lib.attrValues { inherit setup-nsjail time; };

  RUST_LOG = "info,sandkasten=trace,difft=off";

  CONFIG_PATH = "./config.toml:${
    pkgs.writers.writeTOML "sandkasten-config.toml" {
      programs_dir = ".programs";
      jobs_dir = ".jobs";
      nsjail_path = ".nsjail";
      time_path = lib.getExe time;
      environments_path = [ "./pkgs" ];
    }
  }";
}
