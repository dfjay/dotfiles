{
  pkgs,
  lib,
  username,
  userdesc,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  security.sudo.wheelNeedsPassword = false;

  users = {
    defaultUserShell = pkgs.bash;
    mutableUsers = true;
    users.${username} = {
      isNormalUser = true;
      description = userdesc;
      extraGroups = [ "wheel" ];
      initialPassword = "changeme"; # for LISH console only, change after first login
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDE9M/4cz4CbBLjyZlTDaS+MXK5X4wx+Jbap3TN1dRyO9NbXhIkaxNf/FRjKWkuluOeX59m5MsUHccG5D5L5QCUxZigl5oHmWk4Gwc+WNx5R9rSwxiI6fhzWUzyduyKnHlz/UMTmGyvG0Xc/FGMS9TKNaz6lXSyRZtCWaDhsR12URJ7MxkYuU483UT/TS6jcO6k0w+WTCXbdBz4XsK7bKFMbh1Ed36VM4Y/UxCYP4W2VHrLd4+BvqX760bIab0PH5FWHl9Kzg0ff/7Q97atUeMd5r0GfZfS5+SEDORW07rjdeRailE0aq3xDwvugx27BcqCWbIDibSwPjrpZsG1oEfGZ41P+IxEYIIN5YCM4c8MT7hUZ9/ramhIK93pVl5tnlXHloi9VmYiXneGply43DyNw6aGtGquV6AxM7Lz/YtYxr9gK5rFO/L8ZaBmorDSKgROY9GxC7varnZxLb+t6zlSDCz035eH1/8bd0ak7p1TVZnPgx285DzuAcCTaPddLAc= dfjay@Pavels-MacBook-Pro.local"
      ];
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = lib.mkForce "no";
      PasswordAuthentication = false;
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22    # SSH
      443   # HTTPS / sing-box
      80    # HTTP (for cert validation)
    ];
    allowedUDPPorts = [
      443   # sing-box UDP
    ];
  };

  services.sing-box = {
    enable = true;
    settings = {
      log = {
        level = "info";
        timestamp = true;
      };
      inbounds = [
      ];
      outbounds = [
        {
          type = "direct";
          tag = "direct";
        }
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    curl
    wget
    vim
    htop
    git
    mtr
    inetutils
    sysstat
  ];

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  security.sudo.enable = true;

  system.stateVersion = "25.05";
}
