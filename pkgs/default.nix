{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        amdgpu = pkgs.callPackage ./amdgpu { };
        lighthouse = pkgs.callPackage ./lighthouse { };
        lavalink = pkgs.callPackage ./lavalink { };
      };
    };
}
