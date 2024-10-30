{ ... }:

{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        x3d-undervolt = pkgs.callPackage ./x3d-undervolt { };
        amdgpu = pkgs.callPackage ./amdgpu { };
      };
    };
}
