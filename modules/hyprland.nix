{
  nixosModule = { pkgs, username, ... }: {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    programs = {
      kdeconnect.enable = true;
      dconf.enable = true;
    };

    stylix.autoEnable = true;

    security.pam.services.hyprlock = { };

    environment.systemPackages = with pkgs; [
      morewaita-icon-theme
      adwaita-icon-theme
      qogir-icon-theme
      nautilus
      gnome-calendar
      gnome-weather
      gnome-calculator
      gnome-software
      gnome-system-monitor

      wl-clipboard

      # screenshot tools
      grim
      slurp

      # volume control
      pavucontrol

      # automount usb
      udiskie

      hyprland-qtutils
    ];

    services = {
      gvfs.enable = true;
      udisks2.enable = true;
      devmon.enable = true;
    };

    services.greetd = {
      enable = true;
      settings = {
        initial_session = {
          command = "uwsm start hyprland-uwsm.desktop";
          user = "${username}";
        };

        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --greeting 'Welcome to NixOS' --asterisks --remember --remember-user-session --time -cmd uwsm start hyprland-uwsm.desktop";
          user = "greeter";
        };
      };
    };

    nix = {
      settings = {
        substituters = [ "https://hyprland.cachix.org" ];
        trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
      };
    };
  };

  homeModule = { inputs, pkgs, ... }: {
    imports = [
      ./hyprpaper.nix
      ./hyprlock.nix
      ./variables.nix
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

      settings = {
        general = {
          gaps_in = 5;
          gaps_out = 20;

          border_size = 2;

          resize_on_border = false;

          allow_tearing = false;

          layout = "dwindle";
        };

        misc = {
          enable_anr_dialog = false;
        };

        decoration = {
          rounding = 10;
          rounding_power = 2;

          active_opacity = 1.0;
          inactive_opacity = 1.0;

          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
          };

          blur = {
            enabled = true;
            size = 3;
            passes = 1;

            vibrancy = 0.1696;
          };
        };

        animations = {
          enabled = true;

          bezier = [
            "easeOutQuint,0.23,1,0.32,1"
            "easeInOutCubic,0.65,0.05,0.36,1"
            "linear,0,0,1,1"
            "almostLinear,0.5,0.5,0.75,1.0"
            "quick,0.15,0,0.1,1"
          ];

          animation = [
            "global, 1, 10, default"
            "border, 1, 5.39, easeOutQuint"
            "windows, 1, 4.79, easeOutQuint"
            "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
            "windowsOut, 1, 1.49, linear, popin 87%"
            "fadeIn, 1, 1.73, almostLinear"
            "fadeOut, 1, 1.46, almostLinear"
            "fade, 1, 3.03, quick"
            "layers, 1, 3.81, easeOutQuint"
            "layersIn, 1, 4, easeOutQuint, fade"
            "layersOut, 1, 1.5, linear, fade"
            "fadeLayersIn, 1, 1.79, almostLinear"
            "fadeLayersOut, 1, 1.39, almostLinear"
            "workspaces, 1, 1.94, almostLinear, fade"
            "workspacesIn, 1, 1.21, almostLinear, fade"
            "workspacesOut, 1, 1.94, almostLinear, fade"
          ];
        };

        dwindle = {
          pseudotile = true; # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = true; # You probably want this
        };

        "$mod" = "SUPER";
        "$terminal" = "kitty";
        "$fileManager" = "nautilus";
        "$menu" = "rofi -show drun";

        bind = [
          "$mod, Q, exec, $terminal"
          "$mod, C, killactive"
          "$mod, M, exit"
          "$mod, E, exec, $fileManager"
          "$mod, V, togglefloating"
          "$mod, R, exec, $menu"
          "$mod, P, pseudo" # dwindle
          "$mod, J, togglesplit" # dwindle

          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"
          ", Print, exec, grimblast copy area"
          "ALT, Escape, exec, hyprlock"
        ]
        ++ (builtins.concatLists (
          builtins.genList (
            i:
            let
              ws = i + 1;
            in
            [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          ) 9
        ));

        workspace = [
          "1, monitor:DP-2"
          "2, monitor:DP-2"
          "3, monitor:DP-2"
          "4, monitor:DP-2"
          "5, monitor:DP-2"
          "6, monitor:DP-2"
          "7, monitor:DP-2"
          "8, monitor:DP-2"
          "9, monitor:HDMI-A-1"
        ];

        input = {
          kb_layout = "us,ru";
          kb_options = "grp:win_space_toggle";
        };

        monitor = [
          "DP-2, 5120x2160@120, 0x0, 1.25"
          "HDMI-A-1, 3840x2160@60, 512x1728, 1.25"
        ];

        xwayland = {
          force_zero_scaling = true;
        };

        exec-once = [
          "$terminal"
          "hyprlock"
        ];
      };

      extraConfig = ''
        # mouse
        input:sensitivity=-0.6
        input:accel_profile=flat
      '';
    };

    programs.hyprlock = {
      enable = true;
    };

    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        splash = false;
        splash_offset = 2.0;

        preload = [ "./wals/anime1.jpg" ];

        wallpaper = [
          "DP-1,./wals/anime1.jpg"
        ];
      };
    };
  };
}
