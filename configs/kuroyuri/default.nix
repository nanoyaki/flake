{ deps, ... }:

{
  flake.nixosConfigurations = deps.mkSystem {
    hostname = "kuroyuri";
    username = "hana";
    modules = [
      ../common/required
      ../common/optional/audio.nix
      ../common/optional/passkeys
      ../common/optional/fonts.nix
      ../common/optional/shell-utils.nix
      ../common/optional/desktopmanagers/plasma.nix
      ../common/optional/browsers/firefox.nix
      ../common/optional/spotify.nix
      ../common/optional/ssh-settings.nix
      ../common/optional/terminal.nix
      ../common/optional/theme.nix
      ../common/optional/files.nix
      ../common/optional/user-programs.nix
      ../common/optional/editors/vscode.nix
      ../common/optional/mediaplayers/mpv.nix

      ./hardware

      ./configuration.nix
      ./gaming.nix
      ./git.nix
    ];
  };
}
