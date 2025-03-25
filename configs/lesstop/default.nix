{
  deps,
  ...
}:

{
  flake.nixosConfigurations = deps.mkSystem {
    hostname = "lesstop";
    username = "thelessone";
    modules = [
      ../common/required
      ../common/optional/audio.nix
      ../common/optional/fonts.nix
      ../common/optional/shell-utils.nix
      ../common/optional/desktopmanagers/plasma.nix
      ../common/optional/browsers/firefox.nix
      ../common/optional/terminal.nix
      ../common/optional/theme.nix
      ../common/optional/user-programs.nix
      ../common/optional/mediaplayers/mpv.nix
      ../common/optional/vr
      ../common/optional/vr/wivrn.nix
      ../common/optional/gaming
      ../common/optional/cuda.nix

      ./hardware

      ./configuration.nix
      ./theme.nix
      ./programs.nix
      ./vr.nix
    ];
  };
}
