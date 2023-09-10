{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    luajitPackages.readline
    luajitPackages.luarocks
    fnlfmt
  ];

  buildInputs = with pkgs; [
    luajit
    luajitPackages.lgi
    luajitPackages.fennel
    gtk3
    gobject-introspection
  ];
}
