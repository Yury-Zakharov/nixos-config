# home/modules/firefox.nix
{ ... }:

{
  programs.firefox = {
    enable = true;

    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;

      # Curated persistent settings (non-state, non-telemetry from your prefs.js)
      settings = {
        # Privacy & security
        "privacy.globalprivacycontrol.enabled" = true;
        "dom.security.https_only_mode" = true;
        "browser.contentblocking.category" = "custom";
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.allow_list.baseline.enabled" = false;
        "privacy.trackingprotection.allow_list.convenience.enabled" = false;

        # UI / layout (toolbar + sidebar)
        "browser.toolbars.bookmarks.visibility" = "always";
        "sidebar.revamp" = true;
        "sidebar.visibility" = "hide-sidebar";
        "browser.uiCustomization.state" = builtins.toJSON {
          placements = {
            "widget-overflow-fixed-list" = [];
            "unified-extensions-area" = [];
            "nav-bar" = [
              "sidebar-button" "back-button" "forward-button" "stop-reload-button"
              "customizableui-special-spring1" "vertical-spacer" "urlbar-container"
              "customizableui-special-spring2" "downloads-button" "fxa-toolbar-menu-button"
              "unified-extensions-button"
              "_3c078156-979c-498b-8990-85f7987dd929_-browser-action"
              "_testpilot-containers-browser-action"
              "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
              "ublock0_raymondhill_net-browser-action"
            ];
            "toolbar-menubar" = [ "menubar-items" ];
            "TabsToolbar" = [ "firefox-view-button" "tabbrowser-tabs" "new-tab-button" "alltabs-button" ];
            "vertical-tabs" = [];
            "PersonalToolbar" = [ "import-button" "personal-bookmarks" ];
          };
        };

        # General usability
        "browser.startup.page" = 3;                     # restore previous session
        "browser.download.panel.shown" = true;
        "findbar.highlightAll" = true;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "signon.rememberSignons" = false;
      };
    };

    # Extensions — always latest (Firefox auto-updates them), no pinned versions
    policies = {
      DisableTelemetry = true;
      EnableTrackingProtection = true;

      ExtensionSettings = {
        "*" = { installation_mode = "blocked"; };  # block any other extension

        # uBlock Origin
        "uBlock0@raymondhill.net" = {
          installation_mode = "normal_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        };

        # Sidebery
        "{3c078156-979c-498b-8990-85f7987dd929}" = {
          installation_mode = "normal_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/sidebery/latest.xpi";
        };

        # Firefox Multi-Account Containers
        "@testpilot-containers" = {
          installation_mode = "normal_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi";
        };

        # Bitwarden
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          installation_mode = "normal_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
        };

        # Obsidian Web Clipper
        "clipper@obsidian.md" = {
          installation_mode = "normal_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/obsidian-web-clipper/latest.xpi";
        };
      };
    };
  };
}
