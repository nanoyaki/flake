{
  config'.librewolf.enable = true;

  hm.programs.librewolf.settings = {
    # Buttons have dedicated shortcuts
    "browser.toolbars.keyboard_navigation" = false;
    # I'll translate whenever i want
    "browser.translations.automaticallyPopup" = false;
    # Privacy options
    "browser.contentblocking.category" = "strict";
    "privacy.donottrackheader.enabled" = true;
    "privacy.donottrackheader.value" = 1;
    "privacy.purge_trackers.enabled" = true;
    # Blank new tab
    "browser.newtabpage.enabled" = false;
    "browser.newtab.url" = "about:blank";
    "browser.newtabpage.enhanced" = false;
    "browser.newtabpage.introShown" = true;
    "browser.newtab.preload" = false;
    "browser.newtabpage.directory.ping" = "";
    "browser.newtabpage.directory.source" = "data:text/plain,{}";
    # No need for ads
    "browser.newtabpage.activity-stream.enabled" = false;
    "browser.newtabpage.activity-stream.telemetry" = false;
    "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
    "browser.urlbar.suggest.quicksuggest.sponsored" = false;
    # Am aware of the following
    "browser.aboutConfig.showWarning" = false;
    # Disable PiP
    "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;
    # Disable form autfill
    "browser.formfill.enable" = false;
    "extensions.formautofill.addresses.enabled" = false;
    "extensions.formautofill.available" = "off";
    "extensions.formautofill.creditCards.available" = false;
    "extensions.formautofill.creditCards.enabled" = false;
    "extensions.formautofill.heuristics.enabled" = false;
    # Don't log me out from my sites
    "privacy.clearOnShutdown.cookies" = false;
    "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
    "privacy.clearOnShutdown.sessions" = false;
  };
}
