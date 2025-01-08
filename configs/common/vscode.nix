{
  pkgs,
  ...
}:

let
  vscodeExtensions =
    with pkgs.vscode-extensions;
    [
      jnoortheen.nix-ide
      catppuccin.catppuccin-vsc
      catppuccin.catppuccin-vsc-icons
      eamodio.gitlens
      ms-vscode-remote.remote-ssh
      editorconfig.editorconfig
      yzhang.markdown-all-in-one
      rust-lang.rust-analyzer
      tamasfe.even-better-toml
      github.vscode-github-actions
      redhat.vscode-yaml
    ]
    ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "discord-vscode";
        publisher = "icrawl";
        version = "5.8.0";
        sha256 = "sha256-IU/looiu6tluAp8u6MeSNCd7B8SSMZ6CEZ64mMsTNmU=";
      }
      {
        name = "language-hugo-vscode";
        publisher = "budparr";
        version = "1.3.1";
        sha256 = "sha256-9dp8/gLAb8OJnmsLVbOAKAYZ5whavPW2Ak+WhLqEbJk=";
      }
    ];
in

{
  environment.systemPackages = [
    (pkgs.vscode-with-extensions.override {
      inherit vscodeExtensions;
    })
  ];
}
