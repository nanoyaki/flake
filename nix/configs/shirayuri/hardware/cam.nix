{
  flake.nixosModules.shirayuri-cam =
    { pkgs, ... }:

    {
      programs.droidcam.enable = true;
      boot.extraModprobeConfig = ''
        options v4l2loopback video_nr=0 width=1920 max_width=1920 height=1080 max_height=1080 format=YU12 exclusive_caps=1 card_label=Phone debug=1
      '';

      environment.systemPackages = with pkgs; [
        android-tools
        scrcpy
      ];
    };
}
