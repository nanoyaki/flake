{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.passkey ];
  };

  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.passkey ];
  };

  modules.nixos.passkey =
    { pkgs, ... }:

    {
      environment.systemPackages = with pkgs; [ fido2-manage ];
      services.pcscd.enable = true;
    };
}
