{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.passkey ];
  };

  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.passkey ];
  };

  configurations.nixos.shirayuri = {
    imports = [ config.modules.nixos.passkey ];
  };

  modules.nixos.passkey =
    { pkgs, ... }:

    {
      environment.systemPackages = with pkgs; [ fido2-manage ];
      services.pcscd.enable = true;

      services.udev.extraRules = ''
        ACTION=="remove",\
          ENV{ID_BUS}=="usb",\
          ENV{ID_MODEL_ID}=="0024",\
          ENV{ID_VENDOR_ID}=="349e",\
          ENV{ID_VENDOR}=="TOKEN2",\
          RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"

        ACTION=="remove",\
          ENV{ID_BUS}=="usb",\
          ENV{ID_MODEL_ID}=="0407",\
          ENV{ID_VENDOR_ID}=="1050",\
          ENV{ID_VENDOR}=="Yubico",\
          RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
      '';
    };

  modules.nixos.hana =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.services.pcscd.enable {
        programs.git.config = {
          gpg.format = "ssh";
          user.signingkey = "/home/hana/.ssh/id_hasu.pub";

          commit.gpgSign = true;
          tag.gpgSign = true;
        };
      };
    };
}
