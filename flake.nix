{
  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    inherit (nixpkgs) lib;
    eachSystem = lib.genAttrs [
      "x86_64-linux"
    ];
    pkgsFor = eachSystem (system:
      import nixpkgs {
        inherit system;
        overlays = [self.overlay];
      });
  in {
    packages = eachSystem (system: {
      default = self.packages.${system}.lel;
      inherit (pkgsFor.${system}) lel;
    });

    overlay = final: prev: {
      lel = final.callPackage ./default.nix {luaPackages = prev.luajitPackages;};
    };
  };
}
