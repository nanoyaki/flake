{ deps, ... }:

{
  flake.nixosConfigurations = deps.mkSystem {
    hostname = "shirayuri";
    username = "hana";
    modules = [
      ../common/required
      ../common/optional/audio.nix
      ../common/optional/passkeys
      ../common/optional/fonts.nix
      ../common/optional/shell-utils.nix
      ../common/optional/desktopmanagers
      ../common/optional/desktopmanagers/plasma.nix
      # ../common/optional/desktopmanagers/sway.nix
      ../common/optional/browsers/firefox.nix
      ../common/optional/spotify.nix
      ../common/optional/ssh-settings.nix
      ../common/optional/syncthing.nix
      ../common/optional/terminal.nix
      ../common/optional/theme.nix
      ../common/optional/files.nix
      ../common/optional/user-programs.nix
      ../common/optional/vscode.nix
      ../common/optional/mediaplayers/mpv.nix
      ../common/optional/vr
      ../common/optional/vr/monado.nix
      ../common/optional/gaming
      ../common/optional/norgb.nix
      ../common/optional/rofi.nix
      # ../common/optional/wallpaperengine.nix

      ./hardware

      ./configuration.nix
      ./xdg.nix
      ./gaming
      ./emulation.nix
      ./shell.nix
      ./git.nix
      ./transmission.nix
      ./ssh.nix
      ./cam.nix
      ./tailscale.nix
      # ./gluetun.nix
    ];
  };
}
