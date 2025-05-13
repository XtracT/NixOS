{ lib, pkgs, ... }:

let
  # Helper for locked settings, though we'll use these sparingly now
  lock-false = { Value = false; Status = "locked"; };
  lock-true = { Value = true; Status = "locked"; };
in
{
  home-manager.sharedModules = [
    (_: {
      programs.firefox = {
        enable = true;
        # Use wrapFirefox to apply policies.
        # If you don't need policies, you can simplify to: package = pkgs.firefox;
        package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
          extraPolicies = {
            DisableTelemetry = true;
            DisablePocket = true;
            DisableFeedbackCommands = true;
            DisableFirefoxStudies = true;
            OfferToSaveLogins = true; # Default to true, user can change in FF settings
            PasswordManagerEnabled = true; # Default to true
            EncryptedMediaExtensions.Enabled = true; # Important for video playback
            OverrideFirstRunPage = ""; # No forced first run page
            OverridePostUpdatePage = ""; # No forced post-update page
            EnableTrackingProtection = {
              Value = true;
              Cryptomining = true;
              Fingerprinting = true; # Basic fingerprinting protection
              EmailTracking = true; # New in Firefox
            };
            UserMessaging = { # Reduce pop-ups and suggestions from Mozilla
              ExtensionRecommendations = false;
              FeatureRecommendations = false;
              MoreFromMozilla = false;
              SkipOnboarding = true;
              WhatsNew = false;
            };
            # Ensure Firefox doesn't block extensions from working in private browsing by default
            "Extensions" = {
              "allowPrivateBrowsingByDefault" = true;
              "enabledScopes" = 15; # Allow extensions to run broadly
              "autoDisableScopes" = 0; # Don't automatically disable extensions
            };
          };
        };

        profiles = {
          default = {
            id = 0; # Standard ID for the first profile
            name = "default";
            isDefault = true;

            extensions = {
              packages = with pkgs.nur.repos.rycee.firefox-addons; [
                ublock-origin
                darkreader
              ];
              # If you had extension-specific settings, they would go here, e.g.:
              # settings = {
              #   "uBlock0@raymondhill.net" = { ... };
              # };
            };

            # Core settings for privacy and usability
            # We are avoiding most "locked" settings to allow user changes in Firefox UI
            settings = {
              # --- Basic Privacy & Telemetry ---
              "toolkit.telemetry.enabled" = false;
              "toolkit.telemetry.unified" = false;
              "toolkit.telemetry.server" = "data:,"; # Effectively disables sending
              "toolkit.telemetry.archive.enabled" = false;
              "toolkit.telemetry.newProfilePing.enabled" = false;
              "toolkit.telemetry.shutdownPingSender.enabled" = false;
              "toolkit.telemetry.updatePing.enabled" = false;
              "browser.newtabpage.activity-stream.telemetry" = false;
              "browser.ping-centre.telemetry" = false;
              "datareporting.healthreport.uploadEnabled" = false;
              "datareporting.policy.dataSubmissionEnabled" = false;
              "experiments.supported" = false;
              "experiments.enabled" = false;
              "app.normandy.enabled" = false; # Mozilla's system for pushing studies/features

              # --- Feature Disabling ---
              "extensions.pocket.enabled" = false;
              "identity.fxaccounts.enabled" = false; # Disable Firefox Sync by default, user can enable
              "browser.tabs.firefox-view" = false; # Disable the "Firefox View" button/page

              # --- Tracking Protection (sensible defaults) ---
              "privacy.trackingprotection.enabled" = true;
              "privacy.trackingprotection.socialtracking.enabled" = true; # Protects against social media trackers
              "privacy.trackingprotection.cryptomining.enabled" = true;
              "privacy.query_stripping.enabled" = true; # Remove trackers from URLs
              "privacy.donottrackheader.enabled" = true; # Send "Do Not Track" header

              # --- Content Handling ---
              "dom.security.https_only_mode" = true; # Enable HTTPS-Only Mode
              "media.autoplay.default" = 1; # Block audible autoplay (0=allow, 1=block audible, 5=block all)

              # --- User Experience ---
              "browser.startup.page" = 3; # Restore previous session
              "browser.newtab.url" = "about:newtab"; # Or "about:blank" if preferred
              "browser.search.suggest.enabled" = true; # Allow search suggestions
              "signon.rememberSignons" = true; # Allow saving passwords
              "browser.download.useDownloadDir" = true; # Use the default downloads directory
              "browser.shell.checkDefaultBrowser" = true; # Allow Firefox to check if it's default

              # --- Performance (Generally safe defaults) ---
              "gfx.webrender.all" = true; # Enable WebRender
              "media.ffmpeg.vaapi.enabled" = true; # For hardware video acceleration on Linux (if VA-API is set up)
              "widget.dmabuf.force-enabled" = true; # Often needed with VA-API

              # --- IMPORTANT: Avoid settings that clear data on shutdown by default ---
              # "privacy.sanitize.sanitizeOnShutdown" = false; # User can enable this in FF settings if they want
              # "privacy.clearOnShutdown.cache" = false;
              # ... and other privacy.clearOnShutdown.* settings
            };

            # userChrome and userContent can be added here if you have custom CSS
            # userChrome = "";
            # userContent = "";

            # Bookmarks and Search engines are removed as per your request.
            # You can manage them directly in Firefox.
          };
        };
      };
    })
  ];
}
