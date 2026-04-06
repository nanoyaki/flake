{ withSystem, ... }:

{
  flake.nixosModules.shirayuri-headphones =
    { lib, pkgs, ... }:

    let
      pkg = pkgs.linux-arctis-manager;
    in

    {
      environment.systemPackages = [ pkg ];
      services.udev.packages = [ pkg ];

      systemd.user.services.arctis-manager = {
        description = "Arctis Manager";

        wantedBy = [ "graphical-session.target" ];
        restartTriggers = [ pkg ];

        unitConfig = {
          StartLimitInterval = "1min";
          StartLimitBurst = 5;
        };

        serviceConfig = {
          ExecStart = lib.getExe' pkg "lam-daemon";
          Type = "simple";
          Restart = "on-failure";
          RestartSec = 1;
          StartLimitIntervalSec = 60;
          StartLimitBurst = 60;
        };
      };
    };

  perSystem =
    { pkgs, ... }:

    {
      packages.linux-arctis-manager = pkgs.callPackage (
        {
          lib,
          python3Packages,
          fetchFromGitHub,
          pulseaudio,
          libusb1,
          udevCheckHook,
        }:

        python3Packages.buildPythonPackage (finalAttrs: {
          pname = "linux-arctis-manager";
          version = "9ad382e619798d42d1b0d534acd08415d30cc77c";
          pyproject = true;

          src = fetchFromGitHub {
            owner = "elegos";
            repo = "Linux-Arctis-Manager";
            rev = finalAttrs.version;
            hash = "sha256-KzjJRxkLL5+p3f9vxlV0fKaZofWl1jB4tVY4lvmFNeg=";
          };

          postPatch = ''
            substituteInPlace pyproject.toml \
              --replace-fail "uv_build>=0.10.9,<0.11.0" "uv_build" \
              --replace-fail "pyside6>=6.10.1" "pyside6"
          '';

          postInstall = ''
            HOME=$(pwd) $out/bin/lam-cli desktop write
            mv .local/share $out/share

            mkdir -p "$out/etc/udev/rules.d"
            $out/bin/lam-cli udev write-rules --force --rules-path \
              "$out/etc/udev/rules.d/91-steelseries-arctis.rules"
          '';

          buildInputs = [
            pulseaudio
            libusb1
          ];

          build-system = [
            python3Packages.uv-build
          ];

          dependencies = with python3Packages; [
            dbus-next
            pulsectl
            pyside6
            pyudev
            pyusb
            ruamel-yaml
          ];

          nativeInstallCheckInputs = [ udevCheckHook ];

          meta = {
            mainProgram = "lam-gui";
            description = "Open-source replacement for SteelSeries GG";
            homepage = "https://github.com/elegos/Linux-Arctis-Manager";
            maintainers = with lib.maintainers; [ nanoyaki ];
            license = lib.licenses.gpl3;
            platforms = lib.platforms.linux;
          };
        })
      ) { };
    };

  flake.overlays.linux-arctis-manager =
    _: prev:

    withSystem prev.stdenv.hostPlatform.system (
      { config, ... }:

      {
        inherit (config.packages) linux-arctis-manager;
      }
    );
}
