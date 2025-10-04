{
  Tuple,
  # NamedStruct,
  # Map,
  Enum,
  # Char,
  Raw,
  Some,
  # None,
  ...
}:

{
  palette = Enum {
    variant = "Dark";
    value = [
      {
        name = "Catppuccin-Mocha-Pink";
        blue = {
          red = Raw "0.53725490";
          green = Raw "0.70588235";
          blue = Raw "0.98039216";
          alpha = 1.0;
        };
        red = {
          red = Raw "0.95294118";
          green = Raw "0.54509804";
          blue = Raw "0.65882353";
          alpha = 1.0;
        };
        green = {
          red = Raw "0.65098039";
          green = Raw "0.89019608";
          blue = Raw "0.63137255";
          alpha = 1.0;
        };
        yellow = {
          red = Raw "0.97647059";
          green = Raw "0.88627451";
          blue = Raw "0.68627451";
          alpha = 1.0;
        };
        gray_1 = {
          red = Raw "0.09411765";
          green = Raw "0.09411765";
          blue = Raw "0.14509804";
          alpha = 1.0;
        };
        gray_2 = {
          red = Raw "0.11764706";
          green = Raw "0.11764706";
          blue = Raw "0.18039216";
          alpha = 1.0;
        };
        gray_3 = {
          red = Raw "0.19215686";
          green = Raw "0.19607843";
          blue = Raw "0.26666667";
          alpha = 1.0;
        };
        neutral_0 = {
          red = Raw "0.06666667";
          green = Raw "0.06666667";
          blue = Raw "0.10588235";
          alpha = 1.0;
        };
        neutral_1 = {
          red = Raw "0.09411765";
          green = Raw "0.09411765";
          blue = Raw "0.14509804";
          alpha = 1.0;
        };
        neutral_2 = {
          red = Raw "0.11764706";
          green = Raw "0.11764706";
          blue = Raw "0.18039216";
          alpha = 1.0;
        };
        neutral_3 = {
          red = Raw "0.19215686";
          green = Raw "0.19607843";
          blue = Raw "0.26666667";
          alpha = 1.0;
        };
        neutral_4 = {
          red = Raw "0.27058824";
          green = Raw "0.27843137";
          blue = Raw "0.35294118";
          alpha = 1.0;
        };
        neutral_5 = {
          red = Raw "0.34509804";
          green = Raw "0.35686275";
          blue = Raw "0.43921569";
          alpha = 1.0;
        };
        neutral_6 = {
          red = Raw "0.42352941";
          green = Raw "0.43921569";
          blue = Raw "0.52549020";
          alpha = 1.0;
        };
        neutral_7 = {
          red = Raw "0.49803922";
          green = Raw "0.51764706";
          blue = Raw "0.61176471";
          alpha = 1.0;
        };
        neutral_8 = {
          red = Raw "0.57647059";
          green = Raw "0.60000000";
          blue = Raw "0.69803922";
          alpha = 1.0;
        };
        neutral_9 = {
          red = Raw "0.65098039";
          green = Raw "0.67843137";
          blue = Raw "0.78431373";
          alpha = 1.0;
        };
        neutral_10 = {
          red = Raw "0.72941176";
          green = Raw "0.76078431";
          blue = Raw "0.87058824";
          alpha = 1.0;
        };
        bright_green = {
          red = Raw "0.65098039";
          green = Raw "0.89019608";
          blue = Raw "0.63137255";
          alpha = 1.0;
        };
        bright_red = {
          red = Raw "0.95294118";
          green = Raw "0.54509804";
          blue = Raw "0.65882353";
          alpha = 1.0;
        };
        bright_orange = {
          red = Raw "0.98039216";
          green = Raw "0.70196078";
          blue = Raw "0.52941176";
          alpha = 1.0;
        };
        ext_warm_grey = {
          red = Raw "0.57647059";
          green = Raw "0.60000000";
          blue = Raw "0.69803922";
          alpha = 1.0;
        };
        ext_orange = {
          red = Raw "0.98039216";
          green = Raw "0.70196078";
          blue = Raw "0.52941176";
          alpha = 1.0;
        };
        ext_yellow = {
          red = Raw "0.97647059";
          green = Raw "0.88627451";
          blue = Raw "0.68627451";
          alpha = 1.0;
        };
        ext_blue = {
          red = Raw "0.53725490";
          green = Raw "0.70588235";
          blue = Raw "0.98039216";
          alpha = 1.0;
        };
        ext_purple = {
          red = Raw "0.70588235";
          green = Raw "0.74509804";
          blue = Raw "0.99607843";
          alpha = 1.0;
        };
        ext_pink = {
          red = Raw "0.96078431";
          green = Raw "0.76078431";
          blue = Raw "0.90588235";
          alpha = 1.0;
        };
        ext_indigo = {
          red = Raw "0.79607843";
          green = Raw "0.65098039";
          blue = Raw "0.96862745";
          alpha = 1.0;
        };
        accent_blue = {
          red = Raw "0.53725490";
          green = Raw "0.70588235";
          blue = Raw "0.98039216";
          alpha = 1.0;
        };
        accent_red = {
          red = Raw "0.95294118";
          green = Raw "0.54509804";
          blue = Raw "0.65882353";
          alpha = 1.0;
        };
        accent_green = {
          red = Raw "0.65098039";
          green = Raw "0.89019608";
          blue = Raw "0.63137255";
          alpha = 1.0;
        };
        accent_warm_grey = {
          red = Raw "0.57647059";
          green = Raw "0.60000000";
          blue = Raw "0.69803922";
          alpha = 1.0;
        };
        accent_orange = {
          red = Raw "0.98039216";
          green = Raw "0.70196078";
          blue = Raw "0.52941176";
          alpha = 1.0;
        };
        accent_yellow = {
          red = Raw "0.97647059";
          green = Raw "0.88627451";
          blue = Raw "0.68627451";
          alpha = 1.0;
        };
        accent_purple = {
          red = Raw "0.70588235";
          green = Raw "0.74509804";
          blue = Raw "0.99607843";
          alpha = 1.0;
        };
        accent_pink = {
          red = Raw "0.96078431";
          green = Raw "0.76078431";
          blue = Raw "0.90588235";
          alpha = 1.0;
        };
        accent_indigo = {
          red = Raw "0.79607843";
          green = Raw "0.65098039";
          blue = Raw "0.96862745";
          alpha = 1.0;
        };
      }
    ];
  };

  spacing = {
    space_none = 0;
    space_xxxs = 4;
    space_xxs = 8;
    space_xs = 12;
    space_s = 16;
    space_m = 24;
    space_l = 32;
    space_xl = 48;
    space_xxl = 64;
    space_xxxl = 128;
  };

  corner_radii = {
    radius_0 = Tuple [
      0.0
      0.0
      0.0
      0.0
    ];
    radius_xs = Tuple [
      4.0
      4.0
      4.0
      4.0
    ];
    radius_s = Tuple [
      8.0
      8.0
      8.0
      8.0
    ];
    radius_m = Tuple [
      16.0
      16.0
      16.0
      16.0
    ];
    radius_l = Tuple [
      32.0
      32.0
      32.0
      32.0
    ];
    radius_xl = Tuple [
      160.0
      160.0
      160.0
      160.0
    ];
  };

  bg_color = Some {
    red = Raw "0.11764706";
    green = Raw "0.11764706";
    blue = Raw "0.18039216";
    alpha = 1.0;
  };

  text_tint = Some {
    red = Raw "0.80392157";
    green = Raw "0.83921569";
    blue = Raw "0.95686275";
  };

  accent = Some {
    red = Raw "0.96078431";
    green = Raw "0.76078431";
    blue = Raw "0.90588235";
  };

  success = Some {
    red = Raw "0.65098039";
    green = Raw "0.89019608";
    blue = Raw "0.63137255";
  };

  warning = Some {
    red = Raw "0.97647059";
    green = Raw "0.88627451";
    blue = Raw "0.68627451";
  };

  destructive = Some {
    red = Raw "0.95294118";
    green = Raw "0.54509804";
    blue = Raw "0.65882353";
  };

  window_hint = Some {
    red = Raw "0.96078431";
    green = Raw "0.76078431";
    blue = Raw "0.90588235";
  };

  neutral_tint = Some {
    red = Raw "0.49803922";
    green = Raw "0.51764706";
    blue = Raw "0.61176471";
  };

  primary_container_bg = Some {
    red = Raw "0.19215686";
    green = Raw "0.19607843";
    blue = Raw "0.26666667";
    alpha = 1.0;
  };

  secondary_container_bg = Some {
    red = Raw "0.27058824";
    green = Raw "0.27843137";
    blue = Raw "0.35294118";
    alpha = 1.0;
  };

  is_frosted = false;
  gaps = Tuple [
    0
    0
  ];
  active_hint = 0;
}
