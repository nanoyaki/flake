{
  pkgs,
  ...
}:

{
  hm.programs.git = {
    enable = true;
    userName = "nanoyaki";
    userEmail = "hanakretzer@gmail.com";
  };

  environment.systemPackages = with pkgs; [
    gh
    nixfmt-rfc-style
    nixd

    (vscode-with-extensions.override {
      vscodeExtensions =
        with pkgs.vscode-extensions;
        [
          jnoortheen.nix-ide
          catppuccin.catppuccin-vsc
          catppuccin.catppuccin-vsc-icons
          # tamasfe.even-better-toml
          # rust-lang.rust-analyzer
          # prisma.prisma
          eamodio.gitlens
          # biomejs.biome
          ms-vscode-remote.remote-ssh
          editorconfig.editorconfig
          hediet.vscode-drawio
          yzhang.markdown-all-in-one
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          # {
          #   name = "javascript-ejs-support";
          #   publisher = "DigitalBrainstem";
          #   version = "1.3.3";
          #   sha256 = "0s2xazs74j7dgq1ndakfgami3kxk758ydqsgswixcv80705pbxjn";
          # }
          # {
          #   name = "bun-vscode";
          #   publisher = "oven";
          #   version = "0.0.12";
          #   sha256 = "sha256-8+Fqabbwup6Jzm5m8GlWbxTqumqXtWAw5s3VaDht9Us=";
          # }
          {
            name = "discord-vscode";
            publisher = "icrawl";
            version = "5.8.0";
            sha256 = "sha256-IU/looiu6tluAp8u6MeSNCd7B8SSMZ6CEZ64mMsTNmU=";
          }
          # {
          #   name = "vscode-sqlite";
          #   publisher = "alexcvzz";
          #   version = "0.14.1";
          #   sha256 = "sha256-jOQkRgBkUwJupD+cRo/KRahFRs82X3K49DySw6GlU8U=";
          # }
        ];
    })
    jetbrains.rider
  ];

  environment.variables.EDITOR = "code";

  programs.git.enable = true;
  programs.git.lfs.enable = true;

  # :(
  programs.nix-ld.enable = true;
}
