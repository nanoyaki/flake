{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    steamcmd
    steam-run
  ];
}
