{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    oscavmgr
    vrcadvert
  ];
}
