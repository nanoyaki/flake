{
  deps,
  ...
}:

{
  flake.nixosConfigurations = deps.mkSystem {
    hostname = "lesstop";
    username = "thelessone";
    modules = [
      ../common/sops.nix
      ../common/home.nix
      ../common/nix.nix
      ../common/user.nix
      ../common/networking.nix
      ../common/audio.nix
      ../common/input.nix
      ../common/shell.nix
      ../common/plasma.nix
      ../common/firefox.nix
      ../common/mpv.nix
      ../common/terminal.nix
      ../common/vr
      ../common/vr/wivrn.nix
      ../common/gaming

      ./hardware

      ./configuration.nix
      ./locale.nix
      ./theme.nix
      ./programs.nix
      ./vr.nix
    ];
  };
}
