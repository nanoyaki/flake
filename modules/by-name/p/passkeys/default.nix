{
  lib,
  config,
  inputs,
  ...
}:

{
  imports = [
    ./yubikey.nix
    ./yuri.nix
  ];

  hms = [
    inputs.sops-nix.homeModules.sops
    {
      sops.age.keyFile = lib.mkDefault config.sops.age.keyFile;
    }
  ];
}
