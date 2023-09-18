{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    luajitPackages.readline
    luajitPackages.luarocks
    fnlfmt
    (pkgs.callPackage ./fennel-ls.nix {})
  ];

  buildInputs = with pkgs; [
    luajit
    luajitPackages.lgi
    luajitPackages.fennel
    gtk3
    gobject-introspection
  ];
}
