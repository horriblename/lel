{
  lib,
  gtk3,
  gobject-introspection,
  luaPackages,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "lel";
  version = "dev-1";

  src = ./.;

  buildPhase = ''
    make
  '';

  installPhase = ''
    export PREFIX=$out
    make install
  '';

  buildInputs = [
    luaPackages.lgi
    luaPackages.fennel
    gtk3
    gobject-introspection
  ];

  propagatedBuildInputs = [luaPackages.lua];

  meta = {
    description = "An experimental elm-like GTK library for fennel";
    homepage = "https://github.com/horriblename/lel";
    license = lib.licenses.mit;
  };
}
