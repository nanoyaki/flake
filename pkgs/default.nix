{ ... }:

{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        amdgpu = pkgs.callPackage ./amdgpu { };
      };
    };
}
