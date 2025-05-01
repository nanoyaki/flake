{
  services.home-assistant = {
    enable = true;
    extraComponents = [
      # Components required to complete the onboarding
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      # Recommended for fast zlib compression
      # https://www.home-assistant.io/integrations/isal
      "isal"
      "tplink"
      "tplink_tapo"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = { };
    };
  };

  services.homepage-easify.categories."Smart Home".services.Homeassistant = rec {
    description = "Smart home Geräte-Platform";
    icon = "home-assistant.svg";
    href = "http://homeassistant.home.local";
    siteMonitor = href;
  };
}
