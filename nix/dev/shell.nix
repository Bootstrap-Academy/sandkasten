{ pkgs, self, ... }:

let
  setup-nsjail = pkgs.writeShellScript "setup-nsjail.sh" ''
    if [[ "$UID" != 0 ]]; then
      exec sudo "$0" "$@"
    fi
    cp -a ${pkgs.nsjail}/bin/nsjail .nsjail
    chmod +s .nsjail
  '';

  scripts = pkgs.stdenv.mkDerivation {
    name = "scripts";
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/bin \
        && ln -s ${setup-nsjail} $out/bin/setup-nsjail
    '';
  };
in

{
  default = pkgs.mkShell ({
    packages = [
      self.packages.${pkgs.system}.time
      self.packages.${pkgs.system}.generate
      scripts
    ];
    RUST_LOG = "info,sandkasten=trace,difft=off";
  });
}
