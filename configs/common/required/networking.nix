{ lib, username, ... }:

{
  networking.useDHCP = lib.mkDefault true;

  users.users.${username}.extraGroups = [ "networkmanager" ];

  networking.hosts."100.86.224.101" = [ "cache.theless.one" ];
}
