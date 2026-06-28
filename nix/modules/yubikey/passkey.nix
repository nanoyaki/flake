{ withSystem, ... }:

{
  flake.nixosModules.yubikey =
    { pkgs, config, ... }:

    {
      environment.systemPackages = with pkgs; [
        yubikey-manager
        pam_u2f
        keyroost
      ];

      services.pcscd.enable = true;
      services.udev.packages = [ pkgs.yubikey-personalization ];
      hardware.gpgSmartcards.enable = true;

      services.yubikey-agent.enable = true;
      security.pam.sshAgentAuth.enable = true;

      services.gnome.gcr-ssh-agent.enable = false;
      programs.ssh = {
        startAgent = true;
        agentTimeout = "1h";
        askPassword =
          if config.services.desktopManager.plasma6.enable then
            pkgs.kdePackages.ksshaskpass
          else
            pkgs.openssh-askpass;
        extraConfig = ''
          AddKeysToAgent yes
        '';
      };

      sops.secrets."pam/u2f" = {
        sopsFile = ./yuri.yaml;
        format = "yaml";
        owner = config.self.mainUser;
        mode = "400";
      };

      security.pam.u2f = {
        enable = true;
        settings = {
          cue = true;
          authfile = config.sops.secrets."pam/u2f".path;
        };
      };

      security.pam.services = {
        login.u2fAuth = true;
        sudo = {
          u2fAuth = true;
          sshAgentAuth = true;
        };
      };
    };

  flake.homeModules.yubikey =
    { config, pkgs, ... }:

    {
      programs.gpg = {
        enable = true;
        scdaemonSettings.disable-ccid = true;
      };

      services.gpg-agent = {
        enable = true;
        pinentry = {
          package = pkgs.pinentry-qt;
          program = "pinentry";
        };
      };

      sops.secrets."ssh/id_nadesiko" = {
        sopsFile = ./yuri.yaml;
        format = "yaml";
        path = "${config.home.homeDirectory}/.ssh/id_nadesiko";
        mode = "400";
      };

      sops.secrets."ssh/id_hasu" = {
        sopsFile = ./yuri.yaml;
        format = "yaml";
        path = "${config.home.homeDirectory}/.ssh/id_hasu";
        mode = "400";
      };

      home.file."${config.home.homeDirectory}/.ssh/id_nadesiko.pub".text =
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGTdis9sEaWC/dHRq6a5sTrcBQmQuDQ+OxzJQuhnx/daAAAABHNzaDo= hana@shirayuri";
    };

  perSystem =
    { pkgs, ... }:

    {
      packages.keyroost = pkgs.callPackage (
        {
          lib,
          rustPlatform,
          fetchFromGitHub,
          pkg-config,
          autoPatchelfHook,
          pcsclite,
          libxkbcommon,
          vulkan-loader,
          wayland,
          libxcb,
          libGL,
          openssl,
          libx11,
          libglvnd,
          stdenv,
        }:

        rustPlatform.buildRustPackage (finalAttrs: {
          pname = "keyroost";
          version = "0.7.1";

          src = fetchFromGitHub {
            owner = "framefilter";
            repo = "keyroost";
            tag = "v${finalAttrs.version}";
            hash = "sha256-UmnamND9tpbjv/9dZwwRJx2si6fuV+mNi8l2wEwFNc0=";
          };

          nativeBuildInputs = [
            pkg-config
            autoPatchelfHook
          ];

          runtimeDependencies = [
            vulkan-loader
            wayland
            libx11
            libxcb
            libxkbcommon
            libglvnd
          ];

          buildInputs = [
            pcsclite
            openssl

            libGL
            stdenv.cc.cc.lib
          ]
          ++ finalAttrs.runtimeDependencies;

          cargoHash = "sha256-6mQqJkyCXJFlAnQxOPSdDcVOUrriEJbIusqtf3+j57w=";

          postInstall = ''
            mkdir -p $out/share/{applications,icons}

            install -m 644 $src/packaging/flatpak/io.github.framefilter.keyroost.desktop \
              $out/share/applications

            cp -a $src/packaging/icons/hicolor $out/share/icons
          '';

          meta = {
            mainProgram = "keyroost";
            description = "Independent, vendor-neutral app for managing all your hardware security keys in one place";
            maintainers = with lib.maintainers; [ nanoyaki ];
            license = with lib.licenses; [ asl20 ];
          };
        })
      ) { };
    };

  flake.overlays.keyroost =
    _: prev:

    withSystem prev.stdenv.hostPlatform.system (
      { config, ... }:

      {
        inherit (config.packages) keyroost;
      }
    );
}
