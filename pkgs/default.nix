{ ... }:

{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        amdgpu = pkgs.callPackage ./amdgpu { };
        alcom = pkgs.callPackage ./alcom { };
        lighthouse = pkgs.callPackage ./lighthouse { };
      };
    };
}
