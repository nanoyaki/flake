{
  lib,
  config,
  inputs,
  ...
}:

let
  catppuccin = {
    enable = true;
    flavor = "mocha";
  };

  # list -> attrset
  mapProgramThemes =
    programs:
    lib.listToAttrs (
      map (program: {
        name = program;
        value = {
          catppuccin = lib.mkIf config.hm.programs.${program}.enable {
            inherit (catppuccin) flavor enable;
          };
        };
      }) programs
    );
in

{
  imports = [
    inputs.catppuccin.nixosModules.catppuccin
  ];

  catppuccin = {
    inherit (catppuccin) enable flavor;
    accent = "pink";
  };

  boot.loader.grub = {
    inherit catppuccin;
  };

  hm = {
    # Theming (currently unable to use due to catppuccin Qt module)
    catppuccin = {
      inherit (catppuccin) enable flavor;
      accent = "pink";
    };

    qt = {
      enable = true;
      style.name = "kvantum";
      style.catppuccin = {
        inherit (catppuccin) enable flavor;
        apply = true;
        accent = "pink";
      };
      platformTheme.name = "kvantum";
    };

    programs = lib.mkMerge [
      (mapProgramThemes [
        "alacritty"
        "zellij"
        "starship"
        "btop"
        "mpv"
      ])
      {
        zsh.syntaxHighlighting = lib.mkIf config.hm.programs.zsh.enable {
          inherit catppuccin;
        };

        git.delta = lib.mkIf config.hm.programs.git.enable {
          inherit catppuccin;
        };
      }
    ];
  };
}
