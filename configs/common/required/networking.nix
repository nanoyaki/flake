{ lib, username, ... }:

{
  networking.useDHCP = lib.mkDefault true;

  users.users.${username}.extraGroups = [ "networkmanager" ];
}
