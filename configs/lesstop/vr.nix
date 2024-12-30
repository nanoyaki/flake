{ lib, pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "facetracking" ''
      trap 'jobs -p | xargs kill' EXIT

      ${lib.getExe pkgs.vrcadvert} OscAvMgr 9402 9000 --tracking &

      # If using WiVRn
      ${lib.getExe pkgs.oscavmgr} openxr
    '')
  ];

  services.wivrn.package = pkgs.wivrn.override { cudaSupport = true; };
}
